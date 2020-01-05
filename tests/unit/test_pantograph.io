// test_pantograph.io
// Unit verification for lumped mass pantograph dynamics and aerodynamic uplift.

doFile("src/pantograph/LumpedMassPantograph.io")
doFile("src/pantograph/AerodynamicUplift.io")
doFile("src/pantograph/ContactForce.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_pantograph: " .. desc)
    )
)

// 1. Aerodynamic uplift verification
aero := AerodynamicUplift clone setupCoefficients(0.0, 0.12, 0.0058)
// At 0 m/s: 0 N
assert(aero upliftAtVelocityMs(0.0) == 0.0, "Uplift at 0 m/s is 0 N")

// At 300 km/h (83.33 m/s):
// F = 0.12 * 83.33 + 0.0058 * (83.33^2) = 10.0 + 40.27 = 50.27 N
u300 := aero upliftAtVelocityKmh(300.0)
assert((u300 - 50.27) abs < 1.0, "Uplift at 300 km/h is ~50 N")

// 2. Contact force verification
cf := ContactForce clone setupContact(50000.0, 100.0, 0.15)
// Penetration = 0.002 m (2 mm), zero velocity
// F = 50,000 * 0.002 = 100 N
fn1 := cf computeNormalForce(5.302, 5.300, 0.0, 0.0)
assert((fn1 - 100.0) abs < 1e-4, "Contact normal force 100 N for 2mm penetration")

// Separation = -0.005 m (head is 5mm below wire)
// F must be 0 N (unilateral contact)
fn2 := cf computeNormalForce(5.295, 5.300, 0.0, 0.0)
assert(fn2 == 0.0, "Contact separation normal force is 0 N")

// 3. Lumped mass pantograph dynamic stepping
panto := LumpedMassPantograph clone setupModel(6.60, 18.00, 7000.0, 40.0, 70.0, 90.0)
assert(panto m1 == 6.60, "Head mass 6.6 kg")
assert(panto m2 == 18.00, "Frame mass 18.0 kg")
assert(panto staticPreload == 90.0, "Static preload 90 N")

// Apply equilibrium contact force: 90 N contact + 0 N aero
panto stepTime(0.001, 90.0, 0.0)
assert(panto currentX > 0.0, "Pantograph advances along track")
assert(panto contactForce == 90.0, "Recorded contact force 90 N")

("test_pantograph completed successfully with " .. assertions .. " passing assertions") println
