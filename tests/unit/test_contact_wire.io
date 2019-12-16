// test_contact_wire.io
// Unit verification for discretised contact wire, stagger calculation, and node interpolation.

doFile("src/mechanics/ContactWire.io")
doFile("src/mechanics/Material.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_contact_wire: " .. desc)
    )
)

mat := Material CuAg01
wire := ContactWire clone setupDiscretised(mat, 120e-6, 25000.0, 500.0, 1001, 5.30)

assert(wire numNodes == 1001, "Discretised node count")
assert((wire dx - 0.50) abs < 1e-6, "Element length dx = 0.50 m")
assert(wire nominalHeight == 5.30, "Nominal contact wire height 5.30 m")

// Stagger zig-zag verification (+/- 200 mm across 50m span)
stagger0 := wire staggerAt(0.0, 50.0)
staggerMast1 := wire staggerAt(50.0, 50.0)
staggerMast2 := wire staggerAt(100.0, 50.0)
staggerMid := wire staggerAt(25.0, 50.0)

assert((stagger0 - (-0.20)) abs < 1e-4, "Stagger at mast 0: -0.20 m")
assert((staggerMast1 - 0.20) abs < 1e-4, "Stagger at mast 1: +0.20 m")
assert((staggerMast2 - (-0.20)) abs < 1e-4, "Stagger at mast 2: -0.20 m")
assert(staggerMid abs < 1e-4, "Stagger at midspan: 0.00 m")

// Interpolated displacement verification
wire displacement atPut(10, 0.05) // 50 mm uplift at node 10 (x = 5.0 m)
wire displacement atPut(11, 0.07) // 70 mm uplift at node 11 (x = 5.5 m)
dispExact := wire interpolatedDisplacementAt(5.0)
dispInterp := wire interpolatedDisplacementAt(5.25)

assert((dispExact - 0.05) abs < 1e-6, "Exact node displacement")
assert((dispInterp - 0.06) abs < 1e-6, "Linearly interpolated displacement at 5.25m = 0.06 m")

// Tridiagonal stiffness matrix assembly
tri := wire tridiagonalStiffnessVectors
subD := tri at(0)
mainD := tri at(1)
supD := tri at(2)
assert(subD size == 1000, "Subdiagonal length")
assert(mainD size == 1001, "Main diagonal length")
assert(supD size == 1000, "Superdiagonal length")

("test_contact_wire completed successfully with " .. assertions .. " passing assertions") println
