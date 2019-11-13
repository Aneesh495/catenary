// test_complex.io
// Comprehensive unit verification for Complex number arithmetic and polar conversions.

doFile("src/math/Complex.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_complex: " .. desc)
    )
)

c1 := Complex with(3.0, 4.0)
c2 := Complex with(1.0, 2.0)

assert(c1 re == 3.0, "Complex real part")
assert(c1 im == 4.0, "Complex imaginary part")
assert(c1 magnitude == 5.0, "Complex magnitude: sqrt(3^2 + 4^2) = 5")
assert(c1 magnitudeSquared == 25.0, "Complex magnitude squared = 25")

cSum := c1 add(c2)
assert(cSum re == 4.0, "Complex add real: 3 + 1 = 4")
assert(cSum im == 6.0, "Complex add imag: 4 + 2 = 6")

cDiff := c1 subtract(c2)
assert(cDiff re == 2.0, "Complex sub real: 3 - 1 = 2")
assert(cDiff im == 2.0, "Complex sub imag: 4 - 2 = 2")

// (3 + 4i)(1 + 2i) = (3*1 - 4*2) + (3*2 + 4*1)i = -5 + 10i
cProd := c1 multiply(c2)
assert(cProd re == -5.0, "Complex prod real = -5")
assert(cProd im == 10.0, "Complex prod imag = 10")

cDiv := cProd divide(c2)
assert((cDiv re - c1 re) abs < 1e-9, "Complex div inverted real = 3")
assert((cDiv im - c1 im) abs < 1e-9, "Complex div inverted imag = 4")

cScale := c1 scale(2.0)
assert(cScale re == 6.0, "Complex scale real = 6")
assert(cScale im == 8.0, "Complex scale imag = 8")

cConj := c1 conjugate
assert(cConj re == 3.0, "Complex conjugate real = 3")
assert(cConj im == -4.0, "Complex conjugate imag = -4")

cPolar := Complex fromPolar(5.0, 0.0)
assert((cPolar re - 5.0) abs < 1e-9, "Polar at 0 rad real = 5")
assert(cPolar im abs < 1e-9, "Polar at 0 rad imag = 0")

("test_complex completed successfully with " .. assertions .. " passing assertions") println
