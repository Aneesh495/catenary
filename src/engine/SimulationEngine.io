// SimulationEngine.io
// Master multi-rate simulation coordinator uniting mechanical, electrical, and thermal domains.

doFile("src/mechanics/CatenarySystem.io")
doFile("src/pantograph/LumpedMassPantograph.io")
doFile("src/pantograph/AerodynamicUplift.io")
doFile("src/pantograph/ContactForce.io")
doFile("src/pantograph/ActiveControl.io")
doFile("src/arcing/CassieMayrArc.io")
doFile("src/arcing/ContactLossDetector.io")
doFile("src/arcing/WearModel.io")
doFile("src/electrical/NodalAdmittanceSolver.io")
doFile("src/electrical/NeutralSection.io")
doFile("src/protection/DistanceRelay21.io")
doFile("src/protection/ThermalOverload49.io")
doFile("src/protection/Overcurrent50_51.io")
doFile("src/train/TrainFleet.io")
doFile("src/environment/WindModel.io")
doFile("src/environment/TemperatureProfile.io")
doFile("src/environment/FaultInjection.io")
doFile("src/engine/TelemetryRecorder.io")
doFile("src/engine/ActorScheduler.io")

SimulationEngine := Object clone do(
    catenarySystem := nil
    powerSolver := nil
    trainFleet := nil
    neutralSection := nil
    faultEngine := nil
    windModel := nil
    temperatureProfile := nil
    telemetryRecorder := nil

    // Substation protection relays
    distanceRelay := nil
    thermalRelay := nil
    overcurrentRelay := nil

    // Pantograph dynamics & contact models
    pantograph := nil
    aeroModel := nil
    contactModel := nil
    activeController := nil
    arcModel := nil
    contactLossDetector := nil
    wearModel := nil

    // Time parameters
    currentTimeS := 0.0
    dt := 0.001              // 1 millisecond base time step (1000 Hz)
    totalDurationS := 10.0   // Simulation duration [s]
    currentStep := 0

    setupSimulation := method(numSpans, spanLenM, trainSpeedKmh, durationS,
        se := self clone
        se currentTimeS = 0.0
        se dt = 0.001
        se totalDurationS = if(durationS != nil, durationS asNumber, 10.0)
        se currentStep = 0

        // 1. Mechanical catenary line
        nSpans := if(numSpans != nil, numSpans, 10)
        sLen := if(spanLenM != nil, spanLenM, 55.0)
        se catenarySystem = CatenarySystem clone setupStandardSystem(nSpans, sLen)

        // 2. Pantograph and contact models
        vSpeedKmh := if(trainSpeedKmh != nil, trainSpeedKmh, 300.0)
        vSpeedMs := vSpeedKmh / 3.6
        se pantograph = LumpedMassPantograph clone setupModel(6.60, 18.00, 7000.0, 40.0, 70.0, 90.0)
        se pantograph currentVelocity = vSpeedMs
        se pantograph currentX = 20.0 // start at x = 20 m inside span 0

        se aeroModel = AerodynamicUplift clone setupCoefficients(0.0, 0.12, 0.0058)
        se contactModel = ContactForce clone setupContact(50000.0, 100.0, 0.15)
        se activeController = ActiveControl clone setupController(110.0, 1.20, 0.08, 0.02, 60.0)
        se arcModel = CassieMayrArc clone setupArc(1.5e-4, 25000.0, 25.0)
        se contactLossDetector = ContactLossDetector clone setupDetector(5.0, 0.005)
        se wearModel = WearModel clone setupWear(6.0e8, 2.5e-5, 1.8e-11)

        // 3. 2x25 kV Electrical power network
        totalTrackKm := (se catenarySystem totalLength) / 1000.0
        se powerSolver = NodalAdmittanceSolver clone setupNetwork(totalTrackKm)
        sub1 := Substation clone setupSubstation("TPSS-1", 0.0, 60.0, 27500.0, 10.5)
        se powerSolver addSubstation(sub1)

        // 4. Substation Protection Relays
        se distanceRelay = DistanceRelay21 clone setupRelay("RELAY-21", Complex with(4.0, 10.0), 85.0, 120.0, 180.0, 15.0)
        se thermalRelay = ThermalOverload49 clone setupRelay("RELAY-49", 800.0, 85.0, 100.0, 0.15)
        se overcurrentRelay = Overcurrent50_51 clone setupRelay("RELAY-50/51", 1000.0, 0.10, 4.0)

        // 5. Environment & Fault Injection
        se windModel = WindModel clone setupWind(5.0, 2.0, 90.0)
        se temperatureProfile = TemperatureProfile clone setupProfile(15.0, 32.0, 14.0)
        se faultEngine = FaultInjection clone setupEngine
        se telemetryRecorder = TelemetryRecorder clone setupRecorder(1000.0)
        se
    )

    // Executes a single time step dt of the coupled multiphysics system
    step := method(
        t := self currentTimeS
        dt := self dt

        // 1. Evaluate scheduled scenario faults
        self faultEngine evaluateFaults(t, self catenarySystem, self powerSolver)

        // 2. Wind and environmental forces
        vWind := self windModel instantaneousWindSpeed(t)
        tAmb := self temperatureProfile ambientTemperatureAtSecond(t)

        // 3. Pantograph kinematics & contact force
        vTrainMs := self pantograph currentVelocity
        xPanto := self pantograph currentX

        // Wire vertical displacement and stagger at pantograph location
        yWireNom := self catenarySystem contactWire nominalHeight
        yWireDisp := self catenarySystem contactWire interpolatedDisplacementAt(xPanto)
        yWireAbsolute := yWireNom + yWireDisp
        staggerZ := self catenarySystem contactWire staggerAt(xPanto, 55.0)

        // Pantograph head absolute vertical position
        yHeadAbsolute := yWireNom + (self pantograph y1)

        // Normal contact force: F_c = k_c * (y_head - y_wire)^+
        fContact := self contactModel computeNormalForce(yHeadAbsolute, yWireAbsolute, self pantograph v1, 0.0)

        // Aerodynamic uplift on pantograph
        fAero := self aeroModel upliftAtVelocityMs(vTrainMs)

        // Active control corrective uplift
        fActive := self activeController computeCorrection(dt, fContact)

        // Advance pantograph dynamic state
        self pantograph stepTime(dt, fContact, fAero + fActive)

        // 4. Contact loss, arcing & wear dynamics
        separationDistance := if(yWireAbsolute > yHeadAbsolute, yWireAbsolute - yHeadAbsolute, 0.0)
        trainLoadCurrent := 350.0 // Amps nominal
        self arcModel stepArc(dt, separationDistance, trainLoadCurrent)
        self contactLossDetector processSample(dt, fContact)
        self wearModel stepWear(dt, fContact, vTrainMs, self arcModel isArcing, self arcModel arcCurrent)

        // 5. Electrical power network & voltage profile
        trainKm := xPanto / 1000.0
        vCatenaryComplex := self powerSolver solveVoltageProfile(trainKm, 8.5, 1.8)
        vCatenary := vCatenaryComplex re

        // 6. Substation protection relays evaluation
        self distanceRelay evaluateFault(vCatenary, trainLoadCurrent)
        self thermalRelay stepThermal(dt, trainLoadCurrent, tAmb, vWind)
        self overcurrentRelay stepEvaluation(dt, trainLoadCurrent)

        // 7. Telemetry recording
        self telemetryRecorder recordSample(t, xPanto, yHeadAbsolute, fContact, vCatenary, 8.5, self arcModel isArcing)

        // Advance clock
        self currentTimeS = self currentTimeS + dt
        self currentStep = self currentStep + 1
        self
    )

    // Runs complete simulation until totalDurationS
    run := method(
        totalSteps := (self totalDurationS / self dt) round
        for(stepIdx, 1, totalSteps,
            self step
        )
        self
    )
)
