// test_protection_relays.io
// Unit verification for ANSI 21, 49, 50/51 protection relays and fault location.

doFile("src/protection/DistanceRelay21.io")
doFile("src/protection/ThermalOverload49.io")
doFile("src/protection/Overcurrent50_51.io")
doFile("src/protection/FaultLocator.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_protection_relays: " .. desc)
    )
)

// 1. Distance Relay ANSI 21 verification
// 50 km line with Z_line = 8 + j21 Ohm
zLine := Complex with(8.0, 21.0)
relay21 := DistanceRelay21 clone setupRelay("RELAY-21", zLine, 85.0, 120.0, 180.0, 15.0)

assert(relay21 id == "RELAY-21", "Distance relay ID")
assert(relay21 isTripped not, "Initial state untripped")

// Test Case 1A: Normal train load: V = 25 kV, I = 400 A => Z = 62.5 Ohm
// Well outside line impedance
resNormal := relay21 evaluateFault(25000.0, 400.0)
assert(resNormal == 0, "Normal train load does not trip distance relay")
assert(relay21 isTripped not, "Relay not tripped under normal load")

// Test Case 1B: Solid catenary-to-rail short circuit at 15 km (Zone 1):
// V drops to 2400 V, I spikes to 3000 A => Z = 0.8 Ohm, X ~ 0.77 Ohm
resZ1 := relay21 evaluateFault(2400.0, 3000.0)
assert(resZ1 == 1, "Short circuit at 15 km triggers Zone 1 trip")
assert(relay21 isTripped, "Relay is tripped")
assert(relay21 tripZone == 1, "Trip zone is Zone 1")
assert(relay21 tripTimeMs == 20.0, "Zone 1 operates in 20 ms (instantaneous)")

// 2. Thermal Overload ANSI 49 verification
relay49 := ThermalOverload49 clone setupRelay("RELAY-49", 800.0, 85.0, 100.0, 0.15)
assert(relay49 conductorTempC == 25.0, "Initial conductor temperature 25 deg C")
assert(relay49 isAlarm not, "Initial alarm flag false")

// Normal current 500 A for 10 seconds: temperature rises slightly
relay49 stepThermal(10.0, 500.0, 25.0, 1.0)
assert(relay49 conductorTempC > 25.0, "Conductor heats up under current")
assert(relay49 conductorTempC < 85.0, "Conductor stays below alarm threshold")

// Extreme current 2000 A for 60 seconds: heats up past trip
relay49 stepThermal(60.0, 2000.0, 35.0, 0.5)
assert(relay49 isAlarm, "Alarm triggers when temp exceeds 85 deg C")
assert(relay49 conductorTempC > 85.0, "Temperature verified above 85 deg C")

// 3. Overcurrent ANSI 50/51 verification
relay5051 := Overcurrent50_51 clone setupRelay("RELAY-50/51", 1000.0, 0.10, 4.0)
// Current = 5000 A (> 4 * 1000 = 4000 A) => Instantaneous ANSI 50 trip!
res50 := relay5051 stepEvaluation(0.01, 5000.0)
assert(res50 == "TRIP_50", "Instantaneous 50 trip triggered at 5000 A")
assert(relay5051 isTripped50, "ANSI 50 flag true")

// 4. Fault Locator verification
locator := FaultLocator clone setupLocator(0.0, 0.420, 294000.0)
// Measured reactance 4.2 Ohm => distance = 4.2 / 0.420 = 10.0 km
dFault := locator estimateDistanceByReactance(4.2)
assert((dFault - 10.0) abs < 1e-4, "Fault locator estimates 10.0 km from reactance")

// Traveling wave arrival time 34.0 microseconds => distance = 294000 * 34e-6 = 9.996 km ~ 10 km
dWave := locator estimateDistanceByWave(34.0)
assert((dWave - 10.0) abs < 0.1, "Fault locator estimates ~10 km from traveling wave")

("test_protection_relays completed successfully with " .. assertions .. " passing assertions") println
