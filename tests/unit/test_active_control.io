// test_active_control.io
// Unit verification for active pantograph closed-loop PID control and actuator saturation.

doFile("src/pantograph/ActiveControl.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_active_control: " .. desc)
    )
)

ctrl := ActiveControl clone setupController(110.0, 1.20, 0.08, 0.02, 60.0)

assert(ctrl targetForce == 110.0, "Target force 110 N")
assert(ctrl isEnabled, "Controller initially enabled")
assert(ctrl maxActuatorForce == 60.0, "Max actuator force 60 N")

// Scenario 1: Contact force drops to 80 N (error = +30 N below target)
// Positive correction demanded to push frame up
u1 := ctrl computeCorrection(0.001, 80.0)
assert(u1 > 0.0, "Corrective uplift force positive when contact force drops")
assert(u1 <= 60.0, "Actuator force within saturation limit")

// Scenario 2: Contact force spikes to 150 N (error = -40 N above target)
// Negative correction demanded to pull frame down
u2 := ctrl computeCorrection(0.001, 150.0)
assert(u2 < 0.0, "Corrective force negative when contact force spikes")
assert(u2 >= -60.0, "Actuator force within negative saturation limit")

// Scenario 3: Controller disabled
ctrl isEnabled = false
uDisabled := ctrl computeCorrection(0.001, 50.0)
assert(uDisabled == 0.0, "Disabled controller outputs zero force")

("test_active_control completed successfully with " .. assertions .. " passing assertions") println
