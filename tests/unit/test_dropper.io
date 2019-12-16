// test_dropper.io
// Unit verification for unilateral non-linear dropper tension and slackening.

doFile("src/mechanics/Dropper.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_dropper: " .. desc)
    )
)

// Dropper with nominal length L0 = 1.0 m, k = 20,000 N/m, c = 50 N*s/m
d := Dropper clone setupDropper(1, 25.0, 1.0, 20000.0, 50.0)
assert(d id == 1, "Dropper id")
assert(d isSlack not, "Initial state not slack")
assert(d isBroken not, "Initial state not broken")

// Case 1: Wire distance = 1.02 m (extension deltaL = +0.02 m)
// Tension = 20,000 * 0.02 = 400 N
f1 := d computeForce(6.50, 5.48, 0.0, 0.0) // 6.50 - 5.48 = 1.02 m
assert((f1 - 400.0) abs < 1e-4, "Dropper in tension: 400 N")
assert(d isSlack not, "Dropper is stretched, not slack")
assert((d currentTension - 400.0) abs < 1e-4, "Dropper tension slot")

// Case 2: Contact wire uplifted! Distance = 0.95 m (compressed deltaL = -0.05 m)
// Realistic slackening: compressive force must be exactly 0 N
f2 := d computeForce(6.50, 5.55, 0.0, 0.0) // 6.50 - 5.55 = 0.95 m
assert(f2 == 0.0, "Dropper slackening: compressive force must be 0 N")
assert(d isSlack, "Dropper flagged as slack")
assert(d currentTension == 0.0, "Dropper tension slot zeroed")

// Case 3: Dropper breakage fault
d breakDropper
assert(d isBroken, "Dropper broken flag")
f3 := d computeForce(6.50, 5.40, 0.0, 0.0) // even if distance is 1.10m
assert(f3 == 0.0, "Broken dropper cannot support tension")
assert(d currentTension == 0.0, "Broken dropper tension remains zero")

("test_dropper completed successfully with " .. assertions .. " passing assertions") println
