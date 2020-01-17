// test_wear.io
// Unit verification for mechanical Archard abrasive wear and arc erosion.

doFile("src/arcing/WearModel.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_wear: " .. desc)
    )
)

wear := WearModel clone setupWear(6.0e8, 2.5e-5, 1.8e-11)

assert(wear stripHardness == 6.0e8, "Strip hardness 600 MPa")
assert(wear cumulativeMechanicalVolume == 0.0, "Initial mechanical wear 0")
assert(wear cumulativeElectricalVolume == 0.0, "Initial electrical wear 0")

// Test 1: Pure mechanical sliding wear (F = 100 N, v = 83.33 m/s, 1.0 s, no arcing)
// Distance s = 83.33 m
// V_mech = (2.5e-5 * 100 * 83.33) / 6.0e8 = 3.472e-10 m^3
res1 := wear stepWear(1.0, 100.0, 83.33, false, 0.0)
assert((wear cumulativeMechanicalVolume - 3.472e-10) abs < 1e-12, "Mechanical wear volume")
assert(wear cumulativeElectricalVolume == 0.0, "Electrical wear remains zero when no arcing")

// Test 2: Electrical arc erosion (F = 0 N, v = 83.33 m/s, 0.01 s, arcing at 400 A)
// V_elec = 1.8e-11 * (400^1.5) * 0.01 = 1.8e-11 * 8000 * 0.01 = 1.44e-9 m^3
res2 := wear stepWear(0.01, 0.0, 83.33, true, 400.0)
assert((wear cumulativeElectricalVolume - 1.44e-9) abs < 1e-11, "Electrical arc wear volume")
assert(wear totalWearVolume > wear cumulativeMechanicalVolume, "Total wear is sum of both components")

// Test 3: Residual thickness calculation
initThick := 0.025 // 25 mm initial carbon strip thickness
resThick := wear residualThickness(initThick, 0.03)
assert(resThick < initThick, "Residual thickness reduced by wear")
assert(resThick > 0.024, "Slight reduction over short test duration")

("test_wear completed successfully with " .. assertions .. " passing assertions") println
