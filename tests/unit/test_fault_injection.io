// test_fault_injection.io
// Unit verification for programmable fault injection and scheduled triggers.

doFile("src/environment/FaultInjection.io")
doFile("src/mechanics/CatenarySystem.io")
doFile("src/electrical/NodalAdmittanceSolver.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_fault_injection: " .. desc)
    )
)

fi := FaultInjection clone setupEngine
assert(fi events size == 0, "Initial fault events list empty")

// Schedule dropper 5 to break at t = 2.0 s
fi scheduleDropperBreak(2.0, 5)
// Schedule substation 1 to trip at t = 5.0 s
fi scheduleSubstationOutage(5.0, "TPSS-1")
assert(fi events size == 2, "Two fault events scheduled")

cs := CatenarySystem clone setupStandardSystem(5, 55.0)
solver := NodalAdmittanceSolver clone setupNetwork(50.0)
sub := Substation clone setupSubstation("TPSS-1", 0.0, 60.0, 27500.0, 10.5)
solver addSubstation(sub)

// Before t=2.0 (e.g. t=1.0): dropper 5 intact, sub untripped
fi evaluateFaults(1.0, cs, solver)
d5 := nil
cs droppers foreach(d, if(d id == 5, d5 = d))
assert(d5 != nil, "Dropper 5 found")
assert(d5 isBroken not, "Dropper 5 not broken at t=1.0")
assert(sub isTripped not, "Substation not tripped at t=1.0")

// At t=2.5: dropper 5 broken, sub still untripped
fi evaluateFaults(2.5, cs, solver)
assert(d5 isBroken, "Dropper 5 broken at t=2.5 s")
assert(sub isTripped not, "Substation still untripped at t=2.5 s")

// At t=5.5: substation trips
fi evaluateFaults(5.5, cs, solver)
assert(sub isTripped, "Substation tripped at t=5.5 s")

("test_fault_injection completed successfully with " .. assertions .. " passing assertions") println
