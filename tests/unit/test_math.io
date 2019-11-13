// test_math.io
// Comprehensive unit verification for Vector, SparseMatrix, Integrator, and Statistics.

doFile("src/math/Vector.io")
doFile("src/math/SparseMatrix.io")
doFile("src/math/Integrator.io")
doFile("src/math/Statistics.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_math: " .. desc)
    )
)

// 1. Vector tests
v1 := Vector with(1.0, 2.0, 3.0)
v2 := Vector with(4.0, 5.0, 6.0)
assert(v1 size == 3, "Vector size should be 3")
assert(v1 at(0) == 1.0, "Vector index 0")
assert(v1 at(2) == 3.0, "Vector index 2")

vSum := v1 add(v2)
assert(vSum at(0) == 5.0, "Vector add index 0")
assert(vSum at(1) == 7.0, "Vector add index 1")
assert(vSum at(2) == 9.0, "Vector add index 2")

vDiff := v2 subtract(v1)
assert(vDiff at(0) == 3.0, "Vector subtract index 0")
assert(vDiff at(2) == 3.0, "Vector subtract index 2")

vScaled := v1 scale(2.5)
assert(vScaled at(0) == 2.5, "Vector scale index 0")
assert(vScaled at(2) == 7.5, "Vector scale index 2")

dotProduct := v1 dot(v2)
assert(dotProduct == 32.0, "Vector dot product 1*4 + 2*5 + 3*6 = 32")

vNormSq := v1 normSquared
assert(vNormSq == 14.0, "Vector norm squared 1 + 4 + 9 = 14")
assert((v1 norm - (14.0 sqrt)) abs < 1e-9, "Vector Euclidean norm")

// 2. SparseMatrix & Conjugate Gradient tests
sm := SparseMatrix withDimensions(4, 4)
sm atPut(0, 0, 5.0); sm atPut(0, 1, 1.0)
sm atPut(1, 0, 1.0); sm atPut(1, 1, 5.0); sm atPut(1, 2, 1.0)
sm atPut(2, 1, 1.0); sm atPut(2, 2, 5.0); sm atPut(2, 3, 1.0)
sm atPut(3, 2, 1.0); sm atPut(3, 3, 5.0)

b := Vector with(6.0, 7.0, 7.0, 6.0)
xExpected := Vector with(1.0, 1.0, 1.0, 1.0)
xComputed := sm solveCG(b, 200, 1e-10)

for(i, 0, 3,
    assert(((xComputed at(i)) - (xExpected at(i))) abs < 1e-6, "Sparse CG solution index " .. i)
)

// 3. Statistics tests
sample := list(12.0, 15.0, 18.0, 22.0, 28.0)
m := Statistics mean(sample)
assert(m == 19.0, "Sample mean calculation")

minVal := Statistics min(sample)
maxVal := Statistics max(sample)
assert(minVal == 12.0, "Sample minimum")
assert(maxVal == 28.0, "Sample maximum")

sDev := Statistics standardDeviation(sample)
assert(sDev > 0.0, "Sample standard deviation positive")

sMax := Statistics statisticalMax(sample)
sMin := Statistics statisticalMin(sample)
assert(sMax > m, "Statistical max greater than mean")
assert(sMin < m, "Statistical min less than mean")

lossP := Statistics contactLossPercentage(list(100.0, 80.0, 0.0, 75.0), 5.0)
assert(lossP == 25.0, "Contact loss percentage should be 25%")

("test_math completed successfully with " .. assertions .. " passing assertions") println
