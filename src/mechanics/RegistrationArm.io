// RegistrationArm.io
// Steady arm (registration arm) kinematics, lateral stagger holding, and uplift clearance.

RegistrationArm := Object clone do(
    mastIndex := 0
    xPosition := 0.0          // Mast longitudinal position [m]
    stagger := 0.20           // Lateral offset (+/- 0.20 m)
    armLength := 1.10         // Physical arm length [m]
    armMass := 1.20           // Mass of aluminum steady arm tube [kg]
    maxAllowableUplift := 0.12 // Maximum vertical uplift before mechanical stop [m]

    setupArm := method(mastIdx, xPos, staggerM, lenM, massKg, upliftLimitM,
        r := self clone
        r mastIndex = mastIdx
        r xPosition = xPos asNumber
        r stagger = staggerM asNumber
        if(lenM != nil, r armLength = lenM asNumber)
        if(massKg != nil, r armMass = massKg asNumber)
        if(upliftLimitM != nil, r maxAllowableUplift = upliftLimitM asNumber)
        r
    )

    // Equivalent vertical lumped mass added to contact wire at the support point:
    // For a pivoting arm of uniform mass: m_eff = m_arm / 3
    equivalentLumpedMass := method(
        (self armMass) / 3.0
    )

    // Restoring force or stop contact if uplift exceeds allowable clearance
    upliftConstraintForce := method(yDisplacement,
        if(yDisplacement > self maxAllowableUplift,
            // Hard bumper stop stiffness (1e6 N/m)
            excess := yDisplacement - (self maxAllowableUplift)
            -1e6 * excess,
            0.0
        )
    )
)
