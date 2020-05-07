// bench_runner.io
// Master high-throughput performance benchmarking suite for Catenary simulation engine.

doFile("src/engine/SimulationEngine.io")

("================================================================================") println
("                  CATENARY SIMULATION THROUGHPUT BENCHMARK                      ")
("================================================================================") println

speeds := list(250.0, 300.0, 350.0)

speeds foreach(spd,
    ("Benchmarking full multiphysics simulation at " .. spd .. " km/h (500 steps, dt=1ms)...") println
    engine := SimulationEngine clone setupSimulation(10, 55.0, spd, 0.50)

    tStart := Date clone now asNumber
    engine run
    tEnd := Date clone now asNumber

    elapsed := tEnd - tStart
    if(elapsed <= 0.0, elapsed = 0.001)
    stepsPerSec := 500.0 / elapsed
    simRatio := 0.50 / elapsed // Real-time simulation ratio

    (">> Completed 500 steps in " .. elapsed .. " s (" .. stepsPerSec .. " steps/sec, " .. simRatio .. "x real-time)\n") println
)

("================================================================================") println
