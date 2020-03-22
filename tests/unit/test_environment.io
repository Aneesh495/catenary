// test_environment.io
// Unit verification for aerodynamic wind crossflow and diurnal temperature cycles.

doFile("src/environment/WindModel.io")
doFile("src/environment/TemperatureProfile.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_environment: " .. desc)
    )
)

// 1. WindModel verification
wind := WindModel clone setupWind(10.0, 4.0, 90.0)
assert(wind meanWindSpeedMs == 10.0, "Mean wind speed 10 m/s")
assert(wind crosswindAngleDeg == 90.0, "Crosswind angle 90 deg")

vInstant := wind instantaneousWindSpeed(0.0)
assert(vInstant == 10.0, "Instantaneous wind speed at t=0 is 10 m/s")

// Lateral drag force per meter on 12.5mm wire at 10 m/s:
// q = 0.5 * 1.225 * 1.10 * 0.0125 * (10^2) = 0.842 N/m
qDrag := wind lateralDragPerMeter(0.0, 0.0125)
assert((qDrag - 0.842) abs < 0.05, "Lateral drag per meter ~0.84 N/m")

// Midspan blow-off on 55m span at 25 kN tension:
// b_mid = (0.842 * 55^2) / (8 * 25000) = 2547 / 200000 = 0.0127 m = 12.7 mm
bMid := wind midspanBlowOffDisplacement(0.0, 0.0125, 55.0, 25000.0)
assert((bMid - 0.0127) abs < 0.002, "Midspan blow-off ~13 mm")

// 2. TemperatureProfile verification
tempProf := TemperatureProfile clone setupProfile(15.0, 35.0, 14.0)
// At 14:00 (peak hour): temperature should be max = 35.0 deg C
tPeak := tempProf ambientTemperatureAtHour(14.0)
assert((tPeak - 35.0) abs < 1e-4, "Peak temperature at 14:00 is 35 deg C")

// At 02:00 (12 hours later): temperature should be min = 15.0 deg C
tMin := tempProf ambientTemperatureAtHour(2.0)
assert((tMin - 15.0) abs < 1e-4, "Minimum temperature at 02:00 is 15 deg C")

// At 08:00 (mean): temperature should be (15 + 35)/2 = 25.0 deg C
tMean := tempProf ambientTemperatureAtHour(8.0)
assert((tMean - 25.0) abs < 1e-4, "Mean temperature at 08:00 is 25 deg C")

("test_environment completed successfully with " .. assertions .. " passing assertions") println
