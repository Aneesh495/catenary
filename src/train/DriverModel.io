// DriverModel.io
// Autonomous high-speed train driver model with speed tracking PID and eco-coasting logic.

DriverModel := Object clone do(
    targetSpeedMs := 83.33    // Cruising speed setpoint [m/s] (300 km/h)
    speedToleranceMs := 0.50  // Deadband speed window [m/s]
    kp := 0.15                // Proportional speed error gain
    ki := 0.005               // Integral gain
    integralSpeedError := 0.0

    setupDriver := method(targetKmh,
        d := self clone
        if(targetKmh != nil, d targetSpeedMs = targetKmh asNumber / 3.6)
        d integralSpeedError = 0.0
        d
    )

    // Computes throttle command (-1.0 to +1.0) given current train speed
    // and upcoming speed limit / neutral section command
    computeThrottle := method(dt, currentSpeedMs, speedLimitMs, neutralSectionCommand,
        // Override for Neutral Section: coast immediately!
        if(neutralSectionCommand == "OPEN_VCB" or neutralSectionCommand == "COAST",
            return 0.0
        )

        effectiveTarget := if(speedLimitMs != nil and speedLimitMs < self targetSpeedMs,
            speedLimitMs,
            self targetSpeedMs
        )

        speedError := effectiveTarget - currentSpeedMs

        // Eco-coasting deadband: if speed is within +/- 1 km/h of target, coast!
        if(speedError abs < self speedToleranceMs,
            return 0.0
        )

        self integralSpeedError = self integralSpeedError + (speedError * dt)
        if(self integralSpeedError > 20.0, self integralSpeedError = 20.0)
        if(self integralSpeedError < -20.0, self integralSpeedError = -20.0)

        throttle := ((self kp) * speedError) + ((self ki) * (self integralSpeedError))

        // Clamp throttle command between -1.0 (full brake) and +1.0 (full tractive effort)
        if(throttle > 1.0, throttle = 1.0)
        if(throttle < -1.0, throttle = -1.0)
        throttle
    )
)
