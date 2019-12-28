// ActiveControl.io
// Closed-loop active pantograph control to suppress contact force variance and dropper harmonics.

ActiveControl := Object clone do(
    targetForce := 110.0      // Desired constant contact force F_target [N]
    kp := 1.20                // Proportional gain
    ki := 0.08                // Integral gain
    kd := 0.02                // Derivative gain

    maxActuatorForce := 60.0  // Saturation limit for active control actuator [N]
    integralError := 0.0
    previousError := 0.0
    isEnabled := true

    setupController := method(fTarget, pGain, iGain, dGain, maxActuatorN,
        ac := self clone
        if(fTarget != nil, ac targetForce = fTarget asNumber)
        if(pGain != nil, ac kp = pGain asNumber)
        if(iGain != nil, ac ki = iGain asNumber)
        if(dGain != nil, ac kd = dGain asNumber)
        if(maxActuatorN != nil, ac maxActuatorForce = maxActuatorN asNumber)
        ac integralError = 0.0
        ac previousError = 0.0
        ac isEnabled = true
        ac
    )

    // Computes corrective actuation force to apply to pantograph frame
    computeCorrection := method(dt, currentContactForce,
        if(self isEnabled not, return 0.0)

        // Error: positive if current force is below target (need more uplift)
        error := (self targetForce) - currentContactForce

        // Anti-windup integration
        self integralError = self integralError + (error * dt)
        if(self integralError > 100.0, self integralError = 100.0)
        if(self integralError < -100.0, self integralError = -100.0)

        derivative := if(dt > 0.0, (error - (self previousError)) / dt, 0.0)
        self previousError = error

        // PID output
        u := ((self kp) * error) + ((self ki) * (self integralError)) + ((self kd) * derivative)

        // Saturation limits
        if(u > self maxActuatorForce, u = self maxActuatorForce)
        if(u < -self maxActuatorForce, u = -self maxActuatorForce)
        u
    )

    reset := method(
        self integralError = 0.0
        self previousError = 0.0
        self
    )
)
