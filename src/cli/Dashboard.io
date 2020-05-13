// Dashboard.io
// Live ANSI/Unicode terminal telemetry dashboard for real-time corridor monitoring.

Dashboard := Object clone do(
    render := method(engine,
        // Clear screen and cursor home
        // Sequence with(27 asCharacter, "[2J", 27 asCharacter, "[H") print

        buf := Sequence clone
        buf appendSeq("================================================================================\n")
        buf appendSeq("            CATENARY HIGH-SPEED ELECTRIFICATION SCADA DASHBOARD                 \n")
        buf appendSeq("================================================================================\n")

        // 1. Train Motion Status
        panto := engine pantograph
        kmPos := (panto currentX) / 1000.0
        vKmh := (panto currentVelocity) * 3.6
        buf appendSeq("TRAIN STATUS:   Position: " .. (kmPos roundDown(2) asString) .. " km  |  Speed: " .. (vKmh roundDown(1) asString) .. " km/h  |  Time: " .. (engine currentTimeS roundDown(3) asString) .. " s\n")

        // 2. Pantograph-Catenary Interaction
        fContact := panto contactForce
        yHead := 5.30 + (panto y1)
        buf appendSeq("PANTOGRAPH:     Head Height: " .. (yHead roundDown(3) asString) .. " m  |  Contact Force: " .. (fContact roundDown(1) asString) .. " N\n")

        // Contact force ASCII bar graph
        // Scale 0 to 250 N across 30 characters
        barLen := ((fContact / 250.0) * 30.0) round
        if(barLen < 0, barLen = 0)
        if(barLen > 30, barLen = 30)
        barStr := Sequence clone
        for(i, 1, barLen, barStr appendSeq("#"))
        for(i, barLen + 1, 30, barStr appendSeq("."))
        buf appendSeq("FORCE GAUGE:    [" .. barStr .. "] " .. (fContact roundDown(1) asString) .. " / 250 N\n")

        // 3. Electrical Power & Substation
        sub := engine powerSolver substations at(0)
        vCat := 25000.0
        pMW := sub activePowerMW
        buf appendSeq("SUBSTATION:     Voltage: " .. (vCat roundDown(1) asString) .. " V  |  Power Draw: " .. (pMW roundDown(2) asString) .. " MW  |  Current: " .. (sub catenaryCurrentA roundDown(1) asString) .. " A\n")

        // 4. Protection Relay & Arcing Alarms
        dRelay := engine distanceRelay
        tRelay := engine thermalRelay
        ocRelay := engine overcurrentRelay

        r21Status := if(dRelay isTripped, "TRIP [ZONE " .. dRelay tripZone .. "]", "OK")
        r49Status := if(tRelay isTripped, "TRIP [OVERHEAT]", if(tRelay isAlarm, "ALARM", "OK (" .. (tRelay conductorTempC roundDown(1) asString) .. " C)"))
        r50Status := if(ocRelay isTripped50, "TRIP [INST]", "OK")
        arcStatus := if(engine arcModel isArcing, "ACTIVE ARC!", "NONE")

        buf appendSeq("SCADA ALARMS:   Relay 21: " .. r21Status .. "  |  Relay 49: " .. r49Status .. "  |  Relay 50/51: " .. r50Status .. "\n")
        buf appendSeq("ARC MONITOR:    Plasma Arc: " .. arcStatus .. "  |  Cumulative Wear: " .. (engine wearModel totalWearVolume asString) .. " m^3\n")
        buf appendSeq("================================================================================\n")
        buf
    )
)
