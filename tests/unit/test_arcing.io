// test_arcing.io
// Unit verification for Cassie-Mayr arc dynamics and contact loss detection.

doFile("src/arcing/CassieMayrArc.io")
doFile("src/arcing/ContactLossDetector.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_arcing: " .. desc)
    )
)

// 1. Cassie-Mayr dynamic arc test
arc := CassieMayrArc clone setupArc(1.5e-4, 25000.0, 25.0)
assert(arc isArcing not, "Initial state not arcing")
assert(arc cumulativeEnergy == 0.0, "Initial dissipated energy 0 J")

// When gap opens under 400 A load current
arc stepArc(0.0001, 0.002, 400.0) // 2mm gap, 400A
assert(arc isArcing, "Arc ignites when gap opens under traction current")
assert(arc arcVoltage > 0.0, "Arc voltage positive")
assert(arc cumulativeEnergy > 0.0, "Cumulative arc energy accumulates")

// When contact re-closes (separation distance = 0)
arc stepArc(0.0001, 0.0, 400.0)
assert(arc isArcing not, "Arc extinguishes immediately on contact closure")
assert(arc arcVoltage == 0.0, "Arc voltage resets to 0")

// 2. ContactLossDetector test
det := ContactLossDetector clone setupDetector(5.0, 0.005)
assert(det totalMonitoredTime == 0.0, "Initial monitored time 0")
assert(det arcingEventCount == 0, "Initial arcing event count 0")

// Feed 10 ms of nominal contact (100 N)
for(i, 1, 10, det processSample(0.001, 100.0))
assert(det arcingEventCount == 0, "No arcing during nominal contact")
assert(det nqPercentage == 0.0, "NQ is 0.0%")

// Feed 6 ms of complete contact loss (0 N)
for(i, 1, 6, det processSample(0.001, 0.0))
assert(det arcingEventCount == 1, "Arcing event registered after >5ms contact loss")
assert(det nqPercentage > 0.0, "NQ percentage positive after contact loss")

("test_arcing completed successfully with " .. assertions .. " passing assertions") println
