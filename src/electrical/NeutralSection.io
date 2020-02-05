// NeutralSection.io
// Phase break dead zone (neutral section) and automatic vacuum circuit breaker (VCB) switching.

NeutralSection := Object clone do(
    id := "NS-1"
    startX := 25000.0         // Track start coordinate [m] (e.g. km 25.0)
    length := 220.0           // Neutral section dead zone length [m]
    entryBaliseX := 24700.0   // Advance warning balise 300m before entry
    exitBaliseX := 25300.0    // Re-engagement balise 80m after exit

    setupNeutralSection := method(nsId, startPosM, lenM,
        n := self clone
        if(nsId != nil, n id = nsId)
        if(startPosM != nil, n startX = startPosM asNumber)
        if(lenM != nil, n length = lenM asNumber)
        n entryBaliseX = (n startX) - 300.0
        n exitBaliseX = (n startX) + (n length) + 80.0
        n
    )

    endX := method(
        (self startX) + (self length)
    )

    // Checks if coordinate x falls inside the dead section (0 V voltage)
    isDeadZone := method(x,
        (x >= self startX) and (x <= self endX)
    )

    // Determines train circuit breaker command based on train position:
    // Returns: "OPEN_VCB" when entering, "COAST" while inside, "CLOSE_VCB" when clear, "NORMAL" elsewhere
    circuitBreakerCommand := method(x,
        if(x >= self entryBaliseX and x < self startX,
            return "OPEN_VCB"
        )
        if(self isDeadZone(x),
            return "COAST"
        )
        if(x > self endX and x <= self exitBaliseX,
            return "CLOSE_VCB"
        )
        "NORMAL"
    )
)
