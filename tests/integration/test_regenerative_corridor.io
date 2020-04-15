// test_regenerative_corridor.io
// Integration test: Multi-train regenerative energy exchange and BESS absorption.

doFile("src/electrical/NodalAdmittanceSolver.io")
doFile("src/electrical/TrainElectricalLoad.io")
doFile("src/electrical/EnergyStorage.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_regenerative_corridor: " .. desc)
    )
)

("Starting Regenerative Braking Corridor integration test...") println

solver := NodalAdmittanceSolver clone setupNetwork(60.0)
sub := Substation clone setupSubstation("TPSS-1", 0.0, 60.0, 27500.0, 10.5)
solver addSubstation(sub)

bess := EnergyStorage clone setupBESS("BESS-1", 15.0, 2000.0, 4000.0, 0.40)

// Train 1: Motoring, drawing 8.0 MW at km 10.0
train1Load := TrainElectricalLoad clone setupLoad(350.0, 0.88, 0.85, 0.98)
train1Load computeLoad(90000.0, 83.33, 25000.0) // Motoring

// Train 2: Dynamic braking, injecting 4.5 MW at km 18.0
train2Load := TrainElectricalLoad clone setupLoad(350.0, 0.88, 0.85, 0.98)
train2Load computeLoad(-65000.0, 83.33, 25000.0) // Regenerative braking

assert(train1Load isRegenerating not, "Train 1 is motoring")
assert(train2Load isRegenerating, "Train 2 is regenerating")
assert(train2Load activePowerMW < 0.0, "Train 2 active power negative (injected)")

// Net power drawn by both trains in corridor
netCorridorActiveMW := (train1Load activePowerMW) + (train2Load activePowerMW)
("Train 1 Motoring Draw: " .. train1Load activePowerMW .. " MW") println
("Train 2 Regen Injected: " .. (train2Load activePowerMW abs) .. " MW") println
("Net Grid Active Demand: " .. netCorridorActiveMW .. " MW") println

assert(netCorridorActiveMW < train1Load activePowerMW, "Regenerative energy partially offsets grid demand")

// BESS absorbs residual power if excess occurs
initSoC := bess currentSoC
bess stepPower(10.0, 1500.0) // Charge 1.5 MW for 10 seconds
assert(bess currentSoC > initSoC, "BESS charges from available regenerative power")

("test_regenerative_corridor integration test passed with " .. assertions .. " passing assertions") println
