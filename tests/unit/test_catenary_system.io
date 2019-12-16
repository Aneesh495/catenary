// test_catenary_system.io
// Unit verification for multi-span continuous catenary system assembly.

doFile("src/mechanics/CatenarySystem.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_catenary_system: " .. desc)
    )
)

// 10 spans of 55m = 550m total track length
cs := CatenarySystem clone setupStandardSystem(10, 55.0)

assert(cs totalLength == 550.0, "Total system length 550 m")
assert(cs spans size == 10, "Span count 10")
assert(cs registrationArms size == 11, "Registration arm count 11 (10 spans + end mast)")
assert(cs droppers size == 90, "Total droppers = 10 spans * 9 droppers = 90")
assert(cs tensioner != nil, "Tensioner configured")

// Check tensioner nominal tension: 850 kg * 9.80665 * 3 = 25,006.96 N ~ 25 kN
assert((cs tensioner nominalTension - 25006.96) abs < 1.0, "Tensioner nominal tension ~25 kN")

// Dropper forces in static equilibrium
forces := cs computeAllDropperForces
assert(forces size == 90, "Dropper forces vector size")
firstDropperForce := forces at(0)
assert(firstDropperForce >= 0.0, "Dropper static tension non-negative")

("test_catenary_system completed successfully with " .. assertions .. " passing assertions") println
