// test_en50318_benchmark.io
// Integration test: EN 50318 high-speed benchmark validation at 300 km/h.

doFile("src/validation/EN50318Benchmark.io")
doFile("src/validation/ComplianceReport.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_en50318_benchmark: " .. desc)
    )
)

("Starting EN 50318 high-speed validation test at 300 km/h...") println

bench := EN50318Benchmark clone setupBenchmark(300.0)
bench executeRun(0.5) // 500 ms run for integration testing

report := ComplianceReport generateReport(bench)
report println

assert(bench measuredMeanForce > 0.0, "Measured mean contact force positive")
assert(bench measuredStdDev >= 0.0, "Measured standard deviation non-negative")
assert(bench measuredMaxForce <= 250.0, "Maximum contact force does not exceed 250 N limit")
assert(bench isPassMaxForce, "Max contact force passes EN 50318 limit")
assert(bench isPassUplift, "Support wire uplift passes EN 50318 limit")

("test_en50318_benchmark integration test passed with " .. assertions .. " passing assertions") println
