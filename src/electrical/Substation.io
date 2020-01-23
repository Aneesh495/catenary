// Substation.io
// 2x25 kV traction power substation (TPSS) and high-voltage transformer model.

doFile("src/math/Complex.io")

Substation := Object clone do(
    id := "TPSS-1"
    trackLocationKm := 0.0    // Kilometer post along railway corridor
    ratedPowerMVA := 60.0     // Transformer nominal capacity [MVA]
    nominalCatenaryVoltage := 27500.0 // Nominal catenary-to-rail voltage [V] (+27.5 kV)
    nominalFeederVoltage := -27500.0  // Nominal feeder-to-rail voltage [V] (-27.5 kV)
    internalReactancePercent := 10.5  // Short-circuit impedance Uk% (typically 10-12%)

    // Operational telemetry
    activePowerMW := 0.0
    reactivePowerMVAR := 0.0
    apparentPowerMVA := 0.0
    catenaryCurrentA := 0.0
    feederCurrentA := 0.0
    railCurrentA := 0.0
    isTripped := false

    setupSubstation := method(subId, kmPos, mvaCapacity, catVoltageV, ukPercent,
        s := self clone
        if(subId != nil, s id = subId)
        if(kmPos != nil, s trackLocationKm = kmPos asNumber)
        if(mvaCapacity != nil, s ratedPowerMVA = mvaCapacity asNumber)
        if(catVoltageV != nil,
            s nominalCatenaryVoltage = catVoltageV asNumber
            s nominalFeederVoltage = -(catVoltageV asNumber)
        )
        if(ukPercent != nil, s internalReactancePercent = ukPercent asNumber)
        s activePowerMW = 0.0
        s reactivePowerMVAR = 0.0
        s apparentPowerMVA = 0.0
        s isTripped = false
        s
    )

    // Internal transformer source impedance referred to 25 kV side:
    // Z_base = V_nom^2 / S_nom
    // Z_internal = Uk% * Z_base
    internalImpedance := method(
        vNom := self nominalCatenaryVoltage
        sBaseVA := (self ratedPowerMVA) * 1e6
        zBase := (vNom squared) / sBaseVA
        xInternal := ((self internalReactancePercent) / 100.0) * zBase
        rInternal := 0.08 * xInternal // Typical X/R ratio ~ 12
        Complex with(rInternal, xInternal)
    )

    // Computes voltage drop across substation source impedance under current I [A]:
    // DeltaV = I * Z_internal
    sourceVoltageDrop := method(currentAmps,
        zInt := self internalImpedance
        // V_drop ~ I * (R * cos(phi) + X * sin(phi))
        // Assuming typical power factor 0.98 inductive
        cosPhi := 0.98
        sinPhi := (1.0 - (cosPhi squared)) sqrt
        (currentAmps) * (((zInt re) * cosPhi) + ((zInt im) * sinPhi))
    )

    // Updates substation telemetry under train power draw
    updateTelemetry := method(pTrainMW, qTrainMVAR,
        if(self isTripped,
            self activePowerMW = 0.0
            self reactivePowerMVAR = 0.0
            self apparentPowerMVA = 0.0
            return self
        )
        self activePowerMW = pTrainMW
        self reactivePowerMVAR = qTrainMVAR
        self apparentPowerMVA = (((pTrainMW squared) + (qTrainMVAR squared)) sqrt)
        self catenaryCurrentA = ((self apparentPowerMVA) * 1e6) / (self nominalCatenaryVoltage)
        self
    )

    // Trip substation circuit breakers on protection fault
    tripBreaker := method(
        self isTripped = true
        self activePowerMW = 0.0
        self reactivePowerMVAR = 0.0
        self apparentPowerMVA = 0.0
        self
    )
)
