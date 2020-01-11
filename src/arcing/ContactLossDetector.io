// ContactLossDetector.io
// Contact loss micro-separation detection and NQ percentage calculator per EN 50318 / EN 50367.

ContactLossDetector := Object clone do(
    forceThreshold := 5.0      // Contact loss force threshold F_loss [N] (standard 5 N)
    minimumDuration := 0.005  // Minimum arc duration to register as micro-separation [s] (standard 5 ms)

    totalMonitoredTime := 0.0 // Total operational time monitored [s]
    totalArcingTime := 0.0    // Total cumulative duration of contact loss [s]
    arcingEventCount := 0     // Total discrete arcing events registered
    currentArcDuration := 0.0 // Duration of currently ongoing separation [s]
    inSeparation := false     // Current separation state

    setupDetector := method(thresholdN, minDurationS,
        d := self clone
        if(thresholdN != nil, d forceThreshold = thresholdN asNumber)
        if(minDurationS != nil, d minimumDuration = minDurationS asNumber)
        d totalMonitoredTime = 0.0
        d totalArcingTime = 0.0
        d arcingEventCount = 0
        d currentArcDuration = 0.0
        d inSeparation = false
        d
    )

    // Process contact force sample over time step dt
    processSample := method(dt, contactForce,
        self totalMonitoredTime = self totalMonitoredTime + dt

        if(contactForce <= self forceThreshold,
            // Contact is below threshold (separation)
            self currentArcDuration = self currentArcDuration + dt
            if(self inSeparation not and (self currentArcDuration >= self minimumDuration),
                self inSeparation = true
                self arcingEventCount = self arcingEventCount + 1
            )
            if(self inSeparation,
                self totalArcingTime = self totalArcingTime + dt
            ),
            // Contact restored above threshold
            self inSeparation = false
            self currentArcDuration = 0.0
        )
        self
    )

    // Percentage of contact loss: NQ = (t_arc / t_total) * 100%
    nqPercentage := method(
        if(self totalMonitoredTime <= 0.0, return 0.0)
        (self totalArcingTime / self totalMonitoredTime) * 100.0
    )

    // Evaluates EN 50367 compliance: NQ must be <= 0.1% for high-speed operation (v >= 250 km/h)
    isCompliantEN50367 := method(
        self nqPercentage <= 0.10
    )
)
