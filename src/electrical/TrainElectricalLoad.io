// TrainElectricalLoad.io
// Four-quadrant PWM converter train electrical consumption and regenerative braking.

TrainElectricalLoad := Object clone do(
    auxiliaryPowerKW := 350.0  // HVAC, lighting, on-board computers [kW]
    drivetrainEfficiency := 0.88 // Inverter + traction motor efficiency
    regenerativeEfficiency := 0.85 // Regenerative braking recovery efficiency
    powerFactor := 0.98        // Four-quadrant PWM converter displacement factor cos(phi)

    // Dynamic electrical state
    activePowerMW := 0.0       // Positive = drawing power, Negative = regenerative braking
    reactivePowerMVAR := 0.0
    currentAmps := 0.0
    isRegenerating := false

    setupLoad := method(auxKW, etaDrive, etaRegen, cosPhi,
        tel := self clone
        if(auxKW != nil, tel auxiliaryPowerKW = auxKW asNumber)
        if(etaDrive != nil, tel drivetrainEfficiency = etaDrive asNumber)
        if(etaRegen != nil, tel regenerativeEfficiency = etaRegen asNumber)
        if(cosPhi != nil, tel powerFactor = cosPhi asNumber)
        tel activePowerMW = 0.0
        tel reactivePowerMVAR = 0.0
        tel currentAmps = 0.0
        tel isRegenerating = false
        tel
    )

    // Computes train power draw and current given tractive/braking force [N] and speed [m/s]
    // catenaryVoltage: instantaneous local catenary voltage [V]
    computeLoad := method(tractiveForceN, speedMs, catenaryVoltage,
        if(catenaryVoltage <= 0.0, catenaryVoltage = 25000.0)
        pAuxMW := (self auxiliaryPowerKW) / 1000.0
        mechanicalPowerMW := (tractiveForceN * speedMs) / 1e6

        if(tractiveForceN >= 0.0,
            // Motoring mode: drawing power from catenary
            self isRegenerating = false
            self activePowerMW = (mechanicalPowerMW / (self drivetrainEfficiency)) + pAuxMW,
            // Dynamic braking mode: negative mechanical power
            self isRegenerating = true
            brakingMechanicalMW := mechanicalPowerMW abs
            recoveredElectricalMW := brakingMechanicalMW * (self regenerativeEfficiency)
            // Net power injected to catenary (positive injected = negative drawn):
            netInjectedMW := recoveredElectricalMW - pAuxMW
            if(netInjectedMW > 0.0,
                self activePowerMW = -netInjectedMW,
                self activePowerMW = 0.0 // aux absorbed all regen energy
            )
        )

        // Reactive power: Q = P * tan(phi)
        tanPhi := ((1.0 - (self powerFactor squared)) sqrt) / (self powerFactor)
        self reactivePowerMVAR = (self activePowerMW abs) * tanPhi

        // Apparent power S = sqrt(P^2 + Q^2) [MVA]
        sMVA := (((self activePowerMW squared) + (self reactivePowerMVAR squared)) sqrt)
        self currentAmps = (sMVA * 1e6) / catenaryVoltage

        list(self activePowerMW, self reactivePowerMVAR, self currentAmps)
    )
)
