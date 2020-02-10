// test_electrical_network.io
// Unit verification for 2x25 kV substation and power flow solver.

doFile("src/electrical/NodalAdmittanceSolver.io")
doFile("src/electrical/TrainElectricalLoad.io")
doFile("src/electrical/EnergyStorage.io")
doFile("src/electrical/NeutralSection.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_electrical_network: " .. desc)
    )
)

// 1. TrainElectricalLoad verification
load := TrainElectricalLoad clone setupLoad(350.0, 0.88, 0.85, 0.98)
// Motoring: 120 kN tractive effort at 83.33 m/s (300 km/h) = 10 MW mechanical
// Active power = 10 / 0.88 + 0.350 = 11.71 MW
pMotoring := load computeLoad(120000.0, 83.33, 25000.0)
assert(load isRegenerating not, "Train is motoring")
assert((load activePowerMW - 11.71) abs < 0.1, "Motoring active power ~11.7 MW")
assert(load currentAmps > 400.0, "Motoring current > 400 A")

// Regenerative braking: -80 kN braking at 83.33 m/s = -6.67 MW mechanical
// Recovered = 6.67 * 0.85 - 0.350 = 5.32 MW injected
pRegen := load computeLoad(-80000.0, 83.33, 25000.0)
assert(load isRegenerating, "Train in regenerative braking mode")
assert(load activePowerMW < 0.0, "Active power is negative (injected to catenary)")

// 2. NodalAdmittanceSolver & Substation
solver := NodalAdmittanceSolver clone setupNetwork(60.0)
sub1 := Substation clone setupSubstation("TPSS-1", 0.0, 60.0, 27500.0, 10.5)
sub2 := Substation clone setupSubstation("TPSS-2", 50.0, 60.0, 27500.0, 10.5)
solver addSubstation(sub1)
solver addSubstation(sub2)

assert(solver substations size == 2, "Substation count 2")

// Train drawing 10 MW at km 15.0
vTrain := solver solveVoltageProfile(15.0, 10.0, 2.0)
assert(vTrain re > 24000.0, "Catenary voltage remains above 24 kV under heavy load")
assert(vTrain re <= 27500.0, "Catenary voltage does not exceed nominal")
assert(sub1 activePowerMW == 10.0, "Substation 1 supplying train active power")

// 3. EnergyStorage (BESS) verification
bess := EnergyStorage clone setupBESS("BESS-1", 15.0, 2000.0, 4000.0, 0.50)
assert(bess currentSoC == 0.50, "Initial SoC 50%")
// Charge with 2000 kW for 360 seconds (0.1 hours = 200 kWh)
bess stepPower(360.0, 2000.0)
assert(bess currentSoC > 0.50, "BESS SoC increased after charging")

// 4. NeutralSection verification
ns := NeutralSection clone setupNeutralSection("NS-1", 25000.0, 220.0)
assert(ns isDeadZone(25100.0), "Inside dead zone at km 25.1")
assert(ns isDeadZone(24500.0) not, "Outside dead zone at km 24.5")
assert(ns circuitBreakerCommand(24800.0) == "OPEN_VCB", "Advance warning balise opens VCB")
assert(ns circuitBreakerCommand(25100.0) == "COAST", "Dead zone coasts")
assert(ns circuitBreakerCommand(25250.0) == "CLOSE_VCB", "Exit balise re-closes VCB")

("test_electrical_network completed successfully with " .. assertions .. " passing assertions") println
