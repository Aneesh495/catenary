// bench_integrator.io
// Micro-benchmarking harness for numerical ODE integrators and matrix solvers.

doFile("src/math/Vector.io")
doFile("src/math/Matrix.io")
doFile("src/math/Integrator.io")

("================================================================================") println
("                  NUMERICAL INTEGRATOR BENCHMARK HARNESS                        ")
("================================================================================") println

// 1. Tridiagonal Thomas solver benchmark (N = 1000 nodes, 10,000 solves)
n := 1000
subD := Vector zeros(n - 1)
mainD := Vector zeros(n)
supD := Vector zeros(n - 1)
rhs := Vector zeros(n)

for(i, 0, n - 1,
    mainD atPut(i, 2.04)
    rhs atPut(i, 1.0)
    if(i > 0, subD atPut(i - 1, -1.0))
    if(i < n - 1, supD atPut(i, -1.0))
)

("Benchmarking Tridiagonal Thomas solver (N=1000, 1000 iterations)...") println
t0 := Date clone now asNumber

for(k, 1, 1000,
    sol := Matrix solveTridiagonal(subD, mainD, supD, rhs)
)

t1 := Date clone now asNumber
elapsed := t1 - t0
if(elapsed <= 0.0, elapsed = 0.001)
rate := 1000.0 / elapsed
(">> Solved 1000 tridiagonal systems (N=1000) in " .. elapsed .. " s (" .. rate .. " solves/sec)\n") println

// 2. RK4 Harmonic oscillator benchmark (10,000 steps)
f := block(t, y, Vector with(y at(1), -(y at(0))))
yState := Vector with(1.0, 0.0)
dt := 0.001

("Benchmarking RK4 integrator (10,000 steps)...") println
t0 = Date clone now asNumber

for(step, 1, 10000,
    t := step * dt
    yState = Integrator stepRK4(t, yState, dt, f)
)

t1 = Date clone now asNumber
elapsed = t1 - t0
if(elapsed <= 0.0, elapsed = 0.001)
stepRate := 10000.0 / elapsed
(">> Executed 10,000 RK4 integration steps in " .. elapsed .. " s (" .. stepRate .. " steps/sec)\n") println
("================================================================================") println
