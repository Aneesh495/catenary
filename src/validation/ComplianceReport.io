// ComplianceReport.io
// ASCII and Markdown compliance table generator for railway regulatory validation.

ComplianceReport := Object clone do(
    generateReport := method(benchmarkObj,
        buf := Sequence clone
        buf appendSeq("================================================================================\n")
        buf appendSeq("                      EN 50318 SIMULATION VALIDATION REPORT                      \n")
        buf appendSeq("================================================================================\n")
        buf appendSeq("Test Speed: " .. (benchmarkObj speedKmh asString) .. " km/h\n")
        buf appendSeq("--------------------------------------------------------------------------------\n")
        buf appendSeq(String with("Parameter") alignLeft(30))
        buf appendSeq(String with("Target Range / Limit") alignLeft(25))
        buf appendSeq(String with("Measured Value") alignLeft(18))
        buf appendSeq("Status\n")
        buf appendSeq("--------------------------------------------------------------------------------\n")

        // 1. Mean Contact Force
        p1Status := if(benchmarkObj isPassMeanForce, "[ PASS ]", "[ FAIL ]")
        p1Target := (benchmarkObj targetMeanForceMin asString) .. " .. " .. (benchmarkObj targetMeanForceMax asString) .. " N"
        p1Val := (benchmarkObj measuredMeanForce asString) .. " N"
        buf appendSeq(String with("Mean Contact Force (F_m)") alignLeft(30))
        buf appendSeq(String with(p1Target) alignLeft(25))
        buf appendSeq(String with(p1Val) alignLeft(18))
        buf appendSeq(p1Status .. "\n")

        // 2. Standard Deviation
        p2Status := if(benchmarkObj isPassStdDev, "[ PASS ]", "[ FAIL ]")
        p2Target := (benchmarkObj targetStdDevMin asString) .. " .. " .. (benchmarkObj targetStdDevMax asString) .. " N"
        p2Val := (benchmarkObj measuredStdDev asString) .. " N"
        buf appendSeq(String with("Standard Deviation (sigma)") alignLeft(30))
        buf appendSeq(String with(p2Target) alignLeft(25))
        buf appendSeq(String with(p2Val) alignLeft(18))
        buf appendSeq(p2Status .. "\n")

        // 3. Maximum Force
        p3Status := if(benchmarkObj isPassMaxForce, "[ PASS ]", "[ FAIL ]")
        p3Target := "<= " .. (benchmarkObj targetMaxContactForceLimit asString) .. " N"
        p3Val := (benchmarkObj measuredMaxForce asString) .. " N"
        buf appendSeq(String with("Maximum Force (F_max)") alignLeft(30))
        buf appendSeq(String with(p3Target) alignLeft(25))
        buf appendSeq(String with(p3Val) alignLeft(18))
        buf appendSeq(p3Status .. "\n")

        // 4. Contact Loss NQ%
        p4Status := if(benchmarkObj isPassNQ, "[ PASS ]", "[ FAIL ]")
        p4Target := "<= " .. (benchmarkObj targetMaxContactLossNQ asString) .. " %"
        p4Val := (benchmarkObj measuredNQ asString) .. " %"
        buf appendSeq(String with("Contact Loss (NQ%)") alignLeft(30))
        buf appendSeq(String with(p4Target) alignLeft(25))
        buf appendSeq(String with(p4Val) alignLeft(18))
        buf appendSeq(p4Status .. "\n")

        // 5. Support Uplift
        p5Status := if(benchmarkObj isPassUplift, "[ PASS ]", "[ FAIL ]")
        p5Target := "<= " .. (benchmarkObj targetMaxUpliftMm asString) .. " mm"
        p5Val := (benchmarkObj measuredMaxUpliftMm asString) .. " mm"
        buf appendSeq(String with("Support Wire Uplift") alignLeft(30))
        buf appendSeq(String with(p5Target) alignLeft(25))
        buf appendSeq(String with(p5Val) alignLeft(18))
        buf appendSeq(p5Status .. "\n")

        buf appendSeq("================================================================================\n")
        overall := if(benchmarkObj isOverallCompliant, "COMPLIANT WITH EN 50318 STANDARDS", "NON-COMPLIANT")
        buf appendSeq("OVERALL STATUS: " .. overall .. "\n")
        buf appendSeq("================================================================================\n")
        buf
    )
)
