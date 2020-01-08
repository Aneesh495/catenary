// CassieMayrArc.io
// Dynamic electric arc conductance model for contact wire separation under traction load.

CassieMayrArc := Object clone do(
    timeConstant := 1.5e-4    // Arc thermal time constant tau [s] (typically 100-200 microseconds)
    coolingPower := 2.5e4     // Cooling power constant P0 [W]
    arcConstantVoltage := 25.0 // Cassie arc gradient voltage Uc [V]
    minimalConductance := 1e-6 // Minimum leakage conductance [S]

    // Dynamic state
    conductance := 1e-6       // Instantaneous arc conductance g [S]
    arcVoltage := 0.0         // Instantaneous arc voltage V_arc [V]
    arcCurrent := 0.0         // Instantaneous current through arc [A]
    isArcing := false         // Flag indicating active plasma discharge
    cumulativeEnergy := 0.0   // Total dissipated electrical energy in arc [Joules]

    setupArc := method(tauS, p0Watts, ucVolts,
        a := self clone
        if(tauS != nil, a timeConstant = tauS asNumber)
        if(p0Watts != nil, a coolingPower = p0Watts asNumber)
        if(ucVolts != nil, a arcConstantVoltage = ucVolts asNumber)
        a conductance = a minimalConductance
        a isArcing = false
        a cumulativeEnergy = 0.0
        a
    )

    // Advances dynamic Cassie-Mayr arc equation over time step dt:
    // If contact is separated (contactSeparationDistance > 0.0005 m) and tractionCurrent > 0:
    // Combined Cassie-Mayr transition:
    // dg/dt = (1 / tau) * [ (u * i) / (P0 + Uc^2 * g) - g ]
    stepArc := method(dt, contactSeparationDistance, tractionCurrent,
        if(contactSeparationDistance > 0.0005 and tractionCurrent > 0.5,
            // Gap opened under electrical load: arc ignites!
            self isArcing = true
            self arcCurrent = tractionCurrent

            // Instantaneous arc voltage: V = I / g
            v := self arcCurrent / (self conductance)
            if(v > 1500.0, v = 1500.0) // Clamp to max open voltage
            self arcVoltage = v

            // Instantaneous electrical power dissipated in arc: P = V * I
            pArc := (self arcVoltage) * (self arcCurrent)
            self cumulativeEnergy = self cumulativeEnergy + (pArc * dt)

            // Combined Cassie-Mayr differential rate:
            // dg/dt = (1 / tau) * ( (pArc / (P0 + (Uc^2)*g)) - g )
            denomP := (self coolingPower) + ((self arcConstantVoltage squared) * (self conductance))
            dgDt := (1.0 / (self timeConstant)) * ((pArc / denomP) - (self conductance))

            self conductance = self conductance + (dgDt * dt)
            if(self conductance < self minimalConductance,
                self conductance = self minimalConductance
            ),
            // Contact closed or current zero: arc extinguishes immediately
            self isArcing = false
            self arcVoltage = 0.0
            self arcCurrent = 0.0
            // Fast deionization decay
            self conductance = self minimalConductance
        )
        self
    )
)
