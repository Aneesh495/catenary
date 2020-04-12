// test_dual_pantograph.io
// Integration test: Dual pantograph dynamic operation with trailing wave interference.

doFile("src/pantograph/DualPantograph.io")
doFile("src/mechanics/CatenarySystem.io")
doFile("src/math/Statistics.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_dual_pantograph: " .. desc)
    )
)

("Starting Dual Pantograph wave interference integration test...") println

// 10 spans, 550m total track
cs := CatenarySystem clone setupStandardSystem(10, 55.0)

// Dual pantographs spaced at 200m at 300 km/h (83.33 m/s)
dualPanto := DualPantograph clone setupDual(200.0, 300.0, 90.0)

leadForces := List clone
trailForces := List clone

// Simulate 300 ms of travel (dt = 0.001s, 300 steps)
for(i, 1, 300,
    forces := dualPanto stepTime(0.001, cs contactWire)
    leadForces append(forces at(0))
    trailForces append(forces at(1))
)

assert(leadForces size == 300, "Lead forces recorded 300 samples")
assert(trailForces size == 300, "Trail forces recorded 300 samples")

meanLead := Statistics mean(leadForces)
meanTrail := Statistics mean(trailForces)
stdLead := Statistics standardDeviation(leadForces)
stdTrail := Statistics standardDeviation(trailForces)

("Leading pantograph mean force: " .. meanLead .. " N, std: " .. stdLead .. " N") println
("Trailing pantograph mean force: " .. meanTrail .. " N, std: " .. stdTrail .. " N") println

assert(meanLead > 0.0, "Leading pantograph mean contact force positive")
assert(meanTrail > 0.0, "Trailing pantograph mean contact force positive")
assert(dualPanto leadingPantograph currentX > dualPanto trailingPantograph currentX, "Leading pantograph is ahead of trailing pantograph")

("test_dual_pantograph integration test passed with " .. assertions .. " passing assertions") println
