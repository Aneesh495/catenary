// TrainFleet.io
// Multi-train fleet manager and corridor timetable execution executive.

doFile("src/math/Complex.io")
doFile("src/train/TrainDynamics.io")
doFile("src/train/DriverModel.io")

TrainFleet := Object clone do(
    trains := nil
    drivers := nil

    setupFleet := method(
        f := self clone
        f trains = List clone
        f drivers = List clone
        f
    )

    addTrain := method(trainObj, driverObj,
        self trains append(trainObj)
        self drivers append(if(driverObj != nil, driverObj, DriverModel clone setupDriver(300.0)))
        self
    )

    trainCount := method(
        self trains size
    )

    // Advances all trains in the fleet by time step dt:
    stepAllTrains := method(dt, networkSolver, neutralSection,
        for(i, 0, self trains size - 1,
            tr := self trains at(i)
            dr := self drivers at(i)

            // Check neutral section command at train position
            nsCmd := if(neutralSection != nil,
                neutralSection circuitBreakerCommand(tr positionX),
                "NORMAL"
            )

            // Compute driver throttle
            throttle := dr computeThrottle(dt, tr velocityMs, 83.33, nsCmd)

            // Get local catenary voltage from power network solver
            trainKm := (tr positionX) / 1000.0
            vComplex := if(networkSolver != nil,
                networkSolver solveVoltageProfile(trainKm, tr electricalLoad activePowerMW, tr electricalLoad reactivePowerMVAR),
                Complex with(25000.0, 0.0)
            )
            vLocal := vComplex re

            // Advance train motion
            tr stepMotion(dt, throttle, vLocal)
        )
        self
    )
)
