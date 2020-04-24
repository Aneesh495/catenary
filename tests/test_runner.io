// test_runner.io
// Master test execution runner for Catenary unit and integration verification suites.

testFiles := list(
    "tests/unit/test_math.io",
    "tests/unit/test_complex.io",
    "tests/unit/test_matrix.io",
    "tests/unit/test_materials.io",
    "tests/unit/test_dropper.io",
    "tests/unit/test_contact_wire.io",
    "tests/unit/test_catenary_system.io",
    "tests/unit/test_pantograph.io",
    "tests/unit/test_active_control.io",
    "tests/unit/test_arcing.io",
    "tests/unit/test_wear.io",
    "tests/unit/test_transmission_line.io",
    "tests/unit/test_electrical_network.io",
    "tests/unit/test_protection_relays.io",
    "tests/unit/test_train_dynamics.io",
    "tests/unit/test_environment.io",
    "tests/unit/test_fault_injection.io",
    "tests/integration/test_en50318_benchmark.io",
    "tests/integration/test_dual_pantograph.io",
    "tests/integration/test_regenerative_corridor.io",
    "tests/integration/test_dropper_breakage.io",
    "tests/integration/test_protection_trip.io"
)

("================================================================================") println
("                      CATENARY MASTER TEST SUITE RUNNER                         ")
("================================================================================") println
("Executing " .. (testFiles size) .. " test suites across unit and integration domains...\n") println

passedTests := 0
failedTests := 0

testFiles foreach(suitePath,
    (">> Executing test suite: " .. suitePath) println
    status := try(
        doFile(suitePath)
        passedTests = passedTests + 1
        ("   [ PASS ] " .. suitePath .. "\n") println
    ) catch(e,
        failedTests = failedTests + 1
        ("   [ FAIL ] " .. suitePath) println
        ("   Error: " .. (e error) .. "\n") println
    )
)

("================================================================================") println
("TEST SUMMARY:")
("Total suites executed: " .. (testFiles size)) println
("Passed: " .. passedTests) println
("Failed: " .. failedTests) println
("================================================================================") println

if(failedTests > 0,
    System exit(1),
    System exit(0)
)
