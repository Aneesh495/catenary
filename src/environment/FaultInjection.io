// FaultInjection.io
// Programmable scenario fault injection engine for reliability and resilience testing.

FaultInjection := Object clone do(
    events := nil             // List of scheduled fault events

    setupEngine := method(
        fi := self clone
        fi events = List clone
        fi
    )

    // Schedule a dropper breakage event at a given simulation time t
    scheduleDropperBreak := method(triggerTimeS, dropperId,
        evt := Map clone
        evt atPut("type", "DROPPER_BREAK")
        evt atPut("time", triggerTimeS asNumber)
        evt atPut("targetId", dropperId)
        evt atPut("executed", false)
        self events append(evt)
        self
    )

    // Schedule a short-circuit fault event
    scheduleShortCircuit := method(triggerTimeS, locationKm, faultResistanceOhm,
        evt := Map clone
        evt atPut("type", "SHORT_CIRCUIT")
        evt atPut("time", triggerTimeS asNumber)
        evt atPut("locationKm", locationKm asNumber)
        evt atPut("resistance", faultResistanceOhm asNumber)
        evt atPut("executed", false)
        self events append(evt)
        self
    )

    // Schedule a substation outage event
    scheduleSubstationOutage := method(triggerTimeS, substationId,
        evt := Map clone
        evt atPut("type", "SUBSTATION_OUTAGE")
        evt atPut("time", triggerTimeS asNumber)
        evt atPut("substationId", substationId)
        evt atPut("executed", false)
        self events append(evt)
        self
    )

    // Evaluates scheduled faults at current simulation time t:
    evaluateFaults := method(currentTimeS, catenarySystem, powerSolver,
        self events foreach(evt,
            if((evt at("executed") not) and (currentTimeS >= (evt at("time"))),
                evt atPut("executed", true)
                fType := evt at("type")

                if(fType == "DROPPER_BREAK",
                    targetId := evt at("targetId")
                    if(catenarySystem != nil,
                        catenarySystem droppers foreach(d,
                            if(d id == targetId, d breakDropper)
                        )
                    )
                )

                if(fType == "SUBSTATION_OUTAGE",
                    subId := evt at("substationId")
                    if(powerSolver != nil,
                        powerSolver substations foreach(sub,
                            if(sub id == subId, sub tripBreaker)
                        )
                    )
                )
            )
        )
        self
    )
)
