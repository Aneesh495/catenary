// test_protection_trip.io
// Integration test: Catenary-to-rail short circuit fault and ANSI 21 distance relay trip.

doFile("src/engine/SimulationEngine.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_protection_trip: " .. desc)
    )
)

("Starting Catenary Short Circuit and Distance Relay Trip integration test...") println

engine := SimulationEngine clone setupSimulation(5, 55.0, 300.0, 0.10)

assert(engine distanceRelay isTripped not, "Distance relay initially untripped")
assert(engine overcurrentRelay isTripped50 not, "Overcurrent relay initially untripped")

// Simulate short-circuit fault: voltage collapses to 1800 V, fault current surges to 4500 A
vFault := 1800.0
iFault := 4500.0

tripZone := engine distanceRelay evaluateFault(vFault, iFault)
tripStatus50 := engine overcurrentRelay stepEvaluation(0.001, iFault)

("Distance relay trip zone: " .. tripZone .. " (Zone 1 Instantaneous)") println
("Overcurrent relay status: " .. tripStatus50 .. " (Instantaneous 50 Trip)") println

assert(tripZone == 1, "Distance relay trips in Zone 1 (instantaneous feeder trip)")
assert(engine distanceRelay isTripped, "Distance relay isTripped flag set")
assert(tripStatus50 == "TRIP_50", "Overcurrent relay triggers ANSI 50 trip")
assert(engine overcurrentRelay isTripped50, "Overcurrent relay isTripped50 flag set")

("test_protection_trip integration test passed with " .. assertions .. " passing assertions") println
