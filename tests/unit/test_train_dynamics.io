// test_train_dynamics.io
// Unit verification for Davis running resistance, train tractive effort, and driver PID.

doFile("src/train/DavisEquation.io")
doFile("src/train/TrainDynamics.io")
doFile("src/train/DriverModel.io")
doFile("src/train/TrainFleet.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_train_dynamics: " .. desc)
    )
)

// 1. Davis equation verification
davis := DavisEquation clone HighSpeedTrainset
// At 0 km/h: A = 3200 N = 3.2 kN
r0 := davis resistanceAtVelocityKmh(0.0)
assert((r0 - 3.2) abs < 1e-4, "Starting rolling resistance 3.2 kN")

// At 300 km/h (83.33 m/s):
// R = 3200 + 60 * 83.33 + 4.10 * (83.33^2) = 3200 + 5000 + 28470 = 36670 N ~ 36.7 kN
r300 := davis resistanceAtVelocityKmh(300.0)
assert((r300 - 36.67) abs < 1.0, "Running resistance at 300 km/h ~36.7 kN")

// 2. Train dynamics verification
train := TrainDynamics clone setupTrain("ICE-1", 450000.0, 9.6e6, 300000.0, 0.0, 0.0)
assert(train trainMassKg == 450000.0, "Train mass 450 tonnes")
assert(train positionX == 0.0, "Start position 0 m")

// At 0 m/s: full starting tractive effort 300 kN
fTract0 := train availableTractiveEffort
assert(fTract0 == 300000.0, "Starting tractive effort 300 kN")

// Accelerate for 10 seconds at full throttle
for(i, 1, 10, train stepMotion(1.0, 1.0, 25000.0))
assert(train velocityMs > 0.0, "Train accelerates forward")
assert(train positionX > 0.0, "Train position advances")
assert(train electricalLoad activePowerMW > 0.0, "Train draws active power")

// 3. Driver model verification
driver := DriverModel clone setupDriver(300.0) // 83.33 m/s
// When speed is 50 m/s (below target): throttle positive
thr1 := driver computeThrottle(1.0, 50.0, 83.33, "NORMAL")
assert(thr1 > 0.0, "Driver applies positive throttle when below target speed")

// When inside neutral section: throttle must be 0 (coasting)
thrNS := driver computeThrottle(1.0, 50.0, 83.33, "COAST")
assert(thrNS == 0.0, "Driver coasts inside neutral section")

// 4. Train fleet verification
fleet := TrainFleet clone setupFleet
train1 := TrainDynamics clone setupTrain("ICE-1", 450000.0, 9.6e6, 300000.0, 0.0, 0.0)
train2 := TrainDynamics clone setupTrain("ICE-2", 450000.0, 9.6e6, 300000.0, 15000.0, 83.33)
fleet addTrain(train1, nil)
fleet addTrain(train2, nil)

assert(fleet trainCount == 2, "Fleet train count 2")
fleet stepAllTrains(1.0, nil, nil)
assert(train1 positionX > 0.0, "Fleet step advances train 1")
assert(train2 positionX > 15000.0, "Fleet step advances train 2")

("test_train_dynamics completed successfully with " .. assertions .. " passing assertions") println
