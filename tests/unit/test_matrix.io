// test_matrix.io
// Comprehensive unit verification for Matrix operations and linear solvers.

doFile("src/math/Matrix.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_matrix: " .. desc)
    )
)

m := Matrix zeros(2, 3)
assert(m rows == 2, "Matrix rows")
assert(m cols == 3, "Matrix cols")
m atPut(0, 1, 4.5)
assert(m at(0, 1) == 4.5, "Matrix atPut/at")

mId := Matrix identity(3)
for(i, 0, 2,
    for(j, 0, 2,
        expected := if(i == j, 1.0, 0.0)
        assert(mId at(i, j) == expected, "Identity element at " .. i .. "," .. j)
    )
)

// Matrix-vector multiplication
// [1 2] [3] = [3 + 8] = [11]
// [0 4] [4]   [0 + 16]  [16]
mA := Matrix zeros(2, 2)
mA atPut(0, 0, 1.0); mA atPut(0, 1, 2.0)
mA atPut(1, 0, 0.0); mA atPut(1, 1, 4.0)
vX := Vector with(3.0, 4.0)
vY := mA multiplyVector(vX)
assert(vY at(0) == 11.0, "Matrix-vector result row 0")
assert(vY at(1) == 16.0, "Matrix-vector result row 1")

// Matrix transpose
mTrans := mA transpose
assert(mTrans at(0, 0) == 1.0, "Transpose 0,0")
assert(mTrans at(1, 0) == 2.0, "Transpose 1,0 (was 0,1)")
assert(mTrans at(0, 1) == 0.0, "Transpose 0,1 (was 1,0)")
assert(mTrans at(1, 1) == 4.0, "Transpose 1,1")

// Dense linear solver with partial pivoting
// 3x3 system:
// [ 3  2 -1 ] [x0]   [ 1 ]
// [ 2 -2  4 ] [x1] = [-2 ]
// [-1 0.5 -1] [x2]   [ 0 ]
// Solution: x0 = 1, x1 = -2, x2 = -2
m3 := Matrix zeros(3, 3)
m3 atPut(0, 0, 3.0); m3 atPut(0, 1, 2.0); m3 atPut(0, 2, -1.0)
m3 atPut(1, 0, 2.0); m3 atPut(1, 1, -2.0); m3 atPut(1, 2, 4.0)
m3 atPut(2, 0, -1.0); m3 atPut(2, 1, 0.5); m3 atPut(2, 2, -1.0)
b3 := Vector with(1.0, -2.0, 0.0)
x3 := m3 solve(b3)

assert((x3 at(0) - 1.0) abs < 1e-6, "Dense solve x0")
assert((x3 at(1) - (-2.0)) abs < 1e-6, "Dense solve x1")
assert((x3 at(2) - (-2.0)) abs < 1e-6, "Dense solve x2")

// Tridiagonal Thomas algorithm solver (O(N) for wire discretisation)
subD := Vector with(-1.0, -1.0, -1.0)
mainD := Vector with(2.0, 2.0, 2.0, 2.0)
supD := Vector with(-1.0, -1.0, -1.0)
rhs := Vector with(1.0, 0.0, 0.0, 1.0)
xTri := Matrix solveTridiagonal(subD, mainD, supD, rhs)

assert((xTri at(0) - 1.0) abs < 1e-6, "Tridiagonal x0")
assert((xTri at(1) - 1.0) abs < 1e-6, "Tridiagonal x1")
assert((xTri at(2) - 1.0) abs < 1e-6, "Tridiagonal x2")
assert((xTri at(3) - 1.0) abs < 1e-6, "Tridiagonal x3")

("test_matrix completed successfully with " .. assertions .. " passing assertions") println
