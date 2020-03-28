// ActorScheduler.io
// Cooperative coroutine actor scheduler coordinating concurrent trains and SCADA monitors.

ActorScheduler := Object clone do(
    actors := nil
    isExecuting := false
    currentCycle := 0

    setupScheduler := method(
        s := self clone
        s actors = List clone
        s isExecuting = false
        s currentCycle = 0
        s
    )

    registerActor := method(actorName, actorObject, stepMessageName,
        rec := Map clone
        rec atPut("name", actorName)
        rec atPut("target", actorObject)
        rec atPut("message", stepMessageName)
        rec atPut("cycleCount", 0)
        self actors append(rec)
        self
    )

    actorCount := method(
        self actors size
    )

    // Execute one cooperative scheduling round across all registered actors
    scheduleRound := method(dt,
        self currentCycle = self currentCycle + 1
        self actors foreach(rec,
            target := rec at("target")
            msg := rec at("message")
            if(target != nil and msg != nil,
                // Invoke actor step
                target perform(msg, dt)
                rec atPut("cycleCount", (rec at("cycleCount")) + 1)
            )
            // Cooperative yield
            yield
        )
        self
    )
)
