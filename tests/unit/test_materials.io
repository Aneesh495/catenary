// test_materials.io
// Unit verification for conductor materials and wire wave speed calculations.

doFile("src/mechanics/Material.io")
doFile("src/mechanics/ConductorWire.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_materials: " .. desc)
    )
)

cuAg := Material CuAg01
assert(cuAg name == "CuAg0.1", "CuAg material name")
assert(cuAg density == 8910.0, "CuAg density")
assert(cuAg youngsModulus > 1.0e11, "CuAg Youngs modulus")

// Standard 120 mm^2 CuAg contact wire at 25 kN tension
wire := ConductorWire clone setupWire(cuAg, 120e-6, 25000.0, 1000.0)
mu := wire linearMass
// mu = 8910 * 120e-6 = 1.0692 kg/m
assert((mu - 1.0692) abs < 1e-4, "Linear mass mu = 1.0692 kg/m")

// Wave speed c = sqrt(25000 / 1.0692) = 152.91 m/s = 550.48 km/h
cSpeed := wire waveVelocity
cSpeedKmh := wire waveVelocityKmh
assert((cSpeed - 152.91) abs < 0.5, "Wave velocity ~153 m/s")
assert((cSpeedKmh - 550.48) abs < 1.0, "Wave velocity ~550 km/h")

// Operating speed limit (70% of c) ~385 km/h
maxOp := wire maxRecommendedOperatingSpeedKmh
assert((maxOp - 385.3) abs < 1.0, "Max operating speed ~385 km/h")

// Doppler factor at 300 km/h (83.33 m/s)
// Doppler = 1 / (1 - 83.33 / 152.91) ~ 2.197
trainV := 300.0 / 3.6
doppler := wire dopplerFactor(trainV)
assert(doppler > 2.0 and doppler < 2.5, "Doppler factor at 300 km/h")

// Thermal expansion: 1000m wire over +20 deg C swing
// deltaL = 1000 * 1.7e-5 * 20 = 0.34 m = 340 mm
dL := wire thermalExpansionDeltaL(20.0)
assert((dL - 0.34) abs < 1e-4, "Thermal expansion 340 mm for 1000m wire")

("test_materials completed successfully with " .. assertions .. " passing assertions") println
