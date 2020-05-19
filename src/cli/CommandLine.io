// CommandLine.io
// Command-line interface and subcommand router for Catenary.

doFile("src/engine/SimulationEngine.io")
doFile("src/validation/EN50318Benchmark.io")
doFile("src/validation/ComplianceReport.io")
doFile("src/cli/Dashboard.io")
doFile("src/cli/ScenarioRunner.io")

CommandLine := Object clone do(
    printUsage := method(
        ("Catenary: High-Speed Rail Pantograph-Catenary Electrification Engine\n") println
        ("Usage: catenary <command> [options]\n") println
        ("Available commands:") println
        ("  run [speed_kmh] [duration_s]  Run interactive simulation at speed (default 300 km/h, 3s)") println
        ("  benchmark                     Execute EN 50318 regulatory benchmark at 300 km/h") println
        ("  verify                        Execute master test suite runner across all subsystems") println
        ("  scenario <name>               Execute preset scenario from scenario library") println
        ("  export <csv_path>             Run simulation and export telemetry to CSV") println
        ("  help                          Display this command reference\n") println
    )

    execute := method(args,
        if(args size <= 1,
            self printUsage
            return 0
        )

        cmd := args at(1)

        if(cmd == "help" or cmd == "--help" or cmd == "-h",
            self printUsage
            return 0
        )

        if(cmd == "run",
            spd := if(args size >= 3, args at(2) asNumber, 300.0)
            dur := if(args size >= 4, args at(3) asNumber, 2.0)
            (">> Initializing simulation at " .. spd .. " km/h for " .. dur .. " s...") println
            engine := SimulationEngine clone setupSimulation(10, 55.0, spd, dur)
            engine run
            dash := Dashboard render(engine)
            dash println
            return 0
        )

        if(cmd == "benchmark",
            (">> Executing EN 50318 High-Speed Rail Benchmark...") println
            bench := EN50318Benchmark clone setupBenchmark(300.0)
            bench executeRun(3.0)
            rep := ComplianceReport generateReport(bench)
            rep println
            return if(bench isOverallCompliant, 0, 1)
        )

        if(cmd == "verify",
            (">> Launching master verification test runner...") println
            doFile("tests/test_runner.io")
            return 0
        )

        if(cmd == "scenario",
            scName := if(args size >= 3, args at(2), "default_hsr_300kmh")
            ScenarioRunner runScenario(scName, 2.0)
            return 0
        )

        if(cmd == "export",
            outPath := if(args size >= 3, args at(2), "telemetry.csv")
            (">> Running simulation and exporting telemetry to " .. outPath .. "...") println
            engine := SimulationEngine clone setupSimulation(10, 55.0, 300.0, 2.0)
            engine run
            engine telemetryRecorder exportCSV(outPath)
            (">> Export complete: " .. (engine telemetryRecorder sampleCount) .. " rows written to " .. outPath) println
            return 0
        )

        ("Unknown command: " .. cmd .. "\n") println
        self printUsage
        1
    )
)
