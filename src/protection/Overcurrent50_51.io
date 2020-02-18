// Overcurrent50_51.io
// ANSI 50 Instantaneous and ANSI 51 Inverse Definite Minimum Time (IDMT) Overcurrent Relay.

Overcurrent50_51 := Object clone do(
    id := "RELAY-50/51"
    pickupCurrentA := 1000.0    // Pickup current threshold I_s [A]
    timeMultiplierSetting := 0.10 // TMS time multiplier (0.05 to 1.0)
    instantaneousMultiplier := 4.0 // ANSI 50 threshold = 4 * I_s (4000 A)

    // Dynamic integrator for IDMT
    tripAccumulator := 0.0      // Tripping integrator (trips when reaches 1.0)
    isTripped50 := false        // ANSI 50 Instantaneous trip flag
    isTripped51 := false        // ANSI 51 Timed trip flag

    setupRelay := method(relayId, pickupA, tms, instMult,
        oc := self clone
        if(relayId != nil, oc id = relayId)
        if(pickupA != nil, oc pickupCurrentA = pickupA asNumber)
        if(tms != nil, oc timeMultiplierSetting = tms asNumber)
        if(instMult != nil, oc instantaneousMultiplier = instMult asNumber)
        oc tripAccumulator = 0.0
        oc isTripped50 = false
        oc isTripped51 = false
        oc
    )

    // Theoretical IEC 60255 Standard Inverse operating time [s]:
    // t = TMS * 0.14 / [ (I / I_s)^0.02 - 1 ]
    idmtOperatingTime := method(currentA,
        ratio := currentA / (self pickupCurrentA)
        if(ratio <= 1.0, return 999999.0) // No pickup below threshold
        denom := (ratio pow(0.02)) - 1.0
        if(denom <= 0.0, return 999999.0)
        (self timeMultiplierSetting) * 0.14 / denom
    )

    // Advances relay evaluation over time step dt [s]:
    stepEvaluation := method(dt, currentA,
        // Check ANSI 50 Instantaneous
        instThreshold := (self pickupCurrentA) * (self instantaneousMultiplier)
        if(currentA >= instThreshold,
            self isTripped50 = true
            return "TRIP_50"
        )

        // Check ANSI 51 IDMT Timed Overcurrent
        if(currentA > self pickupCurrentA,
            tOp := self idmtOperatingTime(currentA)
            if(tOp < 999999.0,
                self tripAccumulator = self tripAccumulator + (dt / tOp)
                if(self tripAccumulator >= 1.0,
                    self isTripped51 = true
                    return "TRIP_51"
                )
            ),
            // Reset / cooling when current drops below pickup
            self tripAccumulator = self tripAccumulator - (dt * 0.5)
            if(self tripAccumulator < 0.0, self tripAccumulator = 0.0)
        )
        "NORMAL"
    )
)
