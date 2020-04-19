// test_dropper_breakage.io
// Integration test: Catenary dynamic transient response to mid-span dropper snap fault.

doFile("src/engine/SimulationEngine.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_dropper_breakage: " .. desc)
    )
)

("Starting Dropper Breakage Fault transient integration test...") println

engine := SimulationEngine clone setupSimulation(5, 55.0, 300.0, 0.20)

// Schedule dropper 8 to break at t = 0.05 s
engine faultEngine scheduleDropperBreak(0.05, 8)

targetDropper := nil
engine catenarySystem droppers foreach(d, if(d id == 8, targetDropper = d))
assert(targetDropper != nil, "Target dropper 8 found in system")
assert(targetDropper isBroken not, "Dropper 8 initially intact")

// Run simulation across the fault event
engine run

assert(targetDropper isBroken, "Dropper 8 confirmed broken after fault trigger time")
assert(targetDropper currentTension == 0.0, "Broken dropper carries zero tension")
assert(engine telemetryRecorder sampleCount > 0, "Telemetry successfully recorded throughout transient")

("test_dropper_breakage integration test passed with " .. assertions .. " passing assertions") println
