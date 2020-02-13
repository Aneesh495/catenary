// DistanceRelay21.io
// ANSI 21 Distance Protection Relay with mho and quadrilateral impedance characteristics.

doFile("src/math/Complex.io")

DistanceRelay21 := Object clone do(
    id := "RELAY-21"
    lineTotalImpedance := nil // Complex line impedance Z_line = R + jX

    // Zone reach settings (percentage of line impedance)
    zone1ReachPercent := 85.0  // Zone 1: 85% reach, instantaneous (t1 = 0 ms)
    zone2ReachPercent := 120.0 // Zone 2: 120% reach, delayed (t2 = 300 ms)
    zone3ReachPercent := 180.0 // Zone 3: 180% reverse/backup, delayed (t3 = 800 ms)

    // Quadrilateral boundary limits
    rBlinders := 12.0          // Maximum fault resistance R_reach [Ohm]
    xTiltAngleDeg := 85.0      // Line characteristic angle

    // Relay state
    isTripped := false
    tripZone := 0              // 0=None, 1=Zone1, 2=Zone2, 3=Zone3
    tripTimeMs := 0.0
    measuredImpedance := nil

    setupRelay := method(relayId, zLine, z1Pct, z2Pct, z3Pct, rMax,
        r := self clone
        if(relayId != nil, r id = relayId)
        r lineTotalImpedance = if(zLine != nil, zLine, Complex with(4.0, 10.0))
        if(z1Pct != nil, r zone1ReachPercent = z1Pct asNumber)
        if(z2Pct != nil, r zone2ReachPercent = z2Pct asNumber)
        if(z3Pct != nil, r zone3ReachPercent = z3Pct asNumber)
        if(rMax != nil, r rBlinders = rMax asNumber)
        r isTripped = false
        r tripZone = 0
        r tripTimeMs = 0.0
        r measuredImpedance = Complex with(100.0, 100.0) // high initial load impedance
        r
    )

    // Evaluates apparent impedance Z = V / I in the complex R-X plane
    // and determines tripping zone
    evaluateFault := method(voltageV, currentA,
        if(currentA <= 1.0,
            // Low current, no fault
            self isTripped = false
            self tripZone = 0
            return 0
        )
        // Apparent impedance Z_seen = V / I
        zMag := voltageV / currentA
        // In railway feeder faults, phase angle theta ~ 75 degrees (mostly inductive)
        thetaRad := 75.0 * (Number constants pi) / 180.0
        rSeen := zMag * (thetaRad cos)
        xSeen := zMag * (thetaRad sin)
        self measuredImpedance = Complex with(rSeen, xSeen)

        // Zone 1 boundary: X_z1 = X_line * (zone1ReachPercent / 100)
        xLine := self lineTotalImpedance im
        xZ1 := xLine * ((self zone1ReachPercent) / 100.0)
        xZ2 := xLine * ((self zone2ReachPercent) / 100.0)
        xZ3 := xLine * ((self zone3ReachPercent) / 100.0)

        // Check if point (rSeen, xSeen) is inside quadrilateral characteristics
        if(rSeen >= -2.0 and rSeen <= self rBlinders,
            if(xSeen > 0.0 and xSeen <= xZ1,
                // Zone 1 Instantaneous Trip!
                self isTripped = true
                self tripZone = 1
                self tripTimeMs = 20.0 // 1 cycle breaker opening time
                return 1
            )
            if(xSeen > xZ1 and xSeen <= xZ2,
                // Zone 2 Delayed Trip
                self isTripped = true
                self tripZone = 2
                self tripTimeMs = 320.0
                return 2
            )
            if(xSeen > xZ2 and xSeen <= xZ3,
                // Zone 3 Delayed Trip
                self isTripped = true
                self tripZone = 3
                self tripTimeMs = 820.0
                return 3
            )
        )
        // Normal load condition
        self isTripped = false
        self tripZone = 0
        0
    )
)
