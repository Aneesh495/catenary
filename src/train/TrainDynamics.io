// TrainDynamics.io
// Longitudinal high-speed train tractive effort, acceleration, and braking dynamics.

doFile("src/train/DavisEquation.io")
doFile("src/pantograph/LumpedMassPantograph.io")
doFile("src/electrical/TrainElectricalLoad.io")

TrainDynamics := Object clone do(
    id := "TRAIN-1"
    trainMassKg := 450000.0   // Total train mass [kg] (450 tonnes)
    maxTractionPowerWatts := 9.6e6 // Max electrical traction power [W] (9.6 MW)
    maxTractiveEffortN := 300000.0 // Starting tractive effort [N] (300 kN)
    maxBrakingForceN := 250000.0   // Max electro-dynamic braking force [N] (250 kN)

    // Motion state
    positionX := 0.0          // Track position [m]
    velocityMs := 0.0         // Forward velocity [m/s]
    accelerationMs2 := 0.0    // Forward acceleration [m/s^2]
    targetSpeedMs := 83.33    // Target cruising speed [m/s] (300 km/h)

    davisResistance := nil
    pantograph := nil
    electricalLoad := nil

    setupTrain := method(trainId, massKg, powerWatts, maxEffortN, startX, v0Ms,
        t := self clone
        if(trainId != nil, t id = trainId)
        if(massKg != nil, t trainMassKg = massKg asNumber)
        if(powerWatts != nil, t maxTractionPowerWatts = powerWatts asNumber)
        if(maxEffortN != nil, t maxTractiveEffortN = maxEffortN asNumber)
        if(startX != nil, t positionX = startX asNumber)
        if(v0Ms != nil, t velocityMs = v0Ms asNumber)

        t davisResistance = DavisEquation clone HighSpeedTrainset
        t pantograph = LumpedMassPantograph clone setupModel(6.60, 18.00, 7000.0, 40.0, 70.0, 90.0)
        t electricalLoad = TrainElectricalLoad clone setupLoad(350.0, 0.88, 0.85, 0.98)
        t
    )

    // Maximum available tractive effort at current velocity:
    // F_max(v) = min(F_starting, P_max / v)
    availableTractiveEffort := method(
        if(self velocityMs <= 1.0,
            return self maxTractiveEffortN
        )
        powerLimitF := (self maxTractionPowerWatts) / (self velocityMs)
        if(powerLimitF < self maxTractiveEffortN, powerLimitF, self maxTractiveEffortN)
    )

    // Advances train longitudinal dynamics over time step dt [s]:
    // demandedThrottle: -1.0 (full braking) to +1.0 (full acceleration)
    // catenaryVoltage: local catenary voltage [V]
    stepMotion := method(dt, demandedThrottle, catenaryVoltage,
        // 1. Running resistance from Davis equation
        fResistance := self davisResistance resistanceAtVelocityMs(self velocityMs)

        // 2. Applied traction / braking force
        fApplied := 0.0
        if(demandedThrottle >= 0.0,
            // Motoring
            fApplied = demandedThrottle * (self availableTractiveEffort),
            // Braking
            fApplied = demandedThrottle * (self maxBrakingForceN) // negative
        )

        // 3. Net acceleration: a = (F_applied - F_resistance) / mass
        fNet := fApplied - fResistance
        self accelerationMs2 = fNet / (self trainMassKg)

        // 4. Update velocity and position
        self velocityMs = self velocityMs + (self accelerationMs2 * dt)
        if(self velocityMs < 0.0, self velocityMs = 0.0) // do not roll backwards
        self positionX = self positionX + (self velocityMs * dt)

        // Update pantograph position and velocity
        self pantograph currentX = self positionX
        self pantograph currentVelocity = self velocityMs

        // 5. Update electrical load
        self electricalLoad computeLoad(fApplied, self velocityMs, catenaryVoltage)
        self
    )
)
