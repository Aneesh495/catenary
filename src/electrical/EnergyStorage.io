// EnergyStorage.io
// Wayside battery energy storage system (BESS) and supercapacitor energy buffer.

EnergyStorage := Object clone do(
    id := "BESS-1"
    trackLocationKm := 15.0
    capacityKWh := 2000.0     // Total storage energy capacity [kWh]
    maxPowerKW := 4000.0      // Maximum charge/discharge power [kW] (4 MW)
    currentSoC := 0.50        // State of Charge (0.0 to 1.0)
    roundTripEfficiency := 0.92 // Battery round-trip efficiency

    currentPowerKW := 0.0     // Positive = charging (absorbing regen), Negative = discharging

    setupBESS := method(bessId, kmPos, capKWh, pMaxKW, initialSoC,
        b := self clone
        if(bessId != nil, b id = bessId)
        if(kmPos != nil, b trackLocationKm = kmPos asNumber)
        if(capKWh != nil, b capacityKWh = capKWh asNumber)
        if(pMaxKW != nil, b maxPowerKW = pMaxKW asNumber)
        if(initialSoC != nil, b currentSoC = initialSoC asNumber)
        b currentPowerKW = 0.0
        b
    )

    // Charges or discharges storage over time step dt [s]:
    // demandedPowerKW: positive when excess regen power available, negative when grid needs boost
    stepPower := method(dt, demandedPowerKW,
        p := demandedPowerKW
        // Clamp to maximum converter power rating
        if(p > self maxPowerKW, p = self maxPowerKW)
        if(p < -self maxPowerKW, p = -self maxPowerKW)

        // Energy increment in kWh: dE = P * dt / 3600
        if(p > 0.0,
            // Charging
            if(self currentSoC >= 0.98,
                p = 0.0, // Fully charged
                dEnergyKWh := (p * dt / 3600.0) * (self roundTripEfficiency)
                newSoC := (self currentSoC) + (dEnergyKWh / (self capacityKWh))
                if(newSoC > 0.98, newSoC = 0.98)
                self currentSoC = newSoC
            ),
            // Discharging (p < 0)
            if(self currentSoC <= 0.10,
                p = 0.0, // Fully depleted
                dEnergyKWh := ((p abs) * dt / 3600.0)
                newSoC := (self currentSoC) - (dEnergyKWh / (self capacityKWh))
                if(newSoC < 0.10, newSoC = 0.10)
                self currentSoC = newSoC
            )
        )
        self currentPowerKW = p
        p
    )
)
