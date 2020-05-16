// ScenarioRunner.io
// Automated scenario configuration loader and batch execution engine.

doFile("src/engine/SimulationEngine.io")
doFile("src/cli/Dashboard.io")

ScenarioRunner := Object clone do(
    runScenario := method(scenarioName, durationOverride,
        (">> Loading scenario: " .. scenarioName) println
        spd := 300.0
        dur := if(durationOverride != nil, durationOverride asNumber, 2.0)
        nSpans := 10

        if(scenarioName == "high_speed_350kmh",
            spd = 350.0
            nSpans = 12
        )

        engine := SimulationEngine clone setupSimulation(nSpans, 55.0, spd, dur)

        if(scenarioName == "dropper_failure_transient",
            engine faultEngine scheduleDropperBreak(0.50, 8)
        )
        if(scenarioName == "short_circuit_relay_trip",
            engine faultEngine scheduleShortCircuit(0.20, 12.5, 0.5)
        )

        (">> Executing multiphysics simulation for " .. dur .. " seconds at " .. spd .. " km/h...") println
        engine run

        // Display final dashboard state
        dash := Dashboard render(engine)
        dash println

        (">> Scenario completed successfully. Recorded " .. (engine telemetryRecorder sampleCount) .. " telemetry frames.") println
        engine
    )
)
