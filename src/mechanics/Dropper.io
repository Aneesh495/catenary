// Dropper.io
// Non-linear unilateral tension-only dropper model with realistic slackening dynamics.

Dropper := Object clone do(
    id := 0
    xPosition := 0.0          // Longitudinal position along track [m]
    nominalLength := 0.80     // Static equilibrium length L0 [m]
    stiffness := 2.5e4        // Tensile stiffness k_d [N / m]
    damping := 50.0           // Internal damping c_d [N * s / m]
    isBroken := false         // Fault simulation: snapped dropper flag

    // State tracking
    currentTension := 0.0     // Instantaneous restoring force [N]
    isSlack := false          // True when dropper is compressed (tension = 0)
    extensionHistory := nil

    setupDropper := method(dropperId, xPos, lengthL0, kStiffness, cDamping,
        d := self clone
        d id = dropperId
        d xPosition = xPos asNumber
        d nominalLength = lengthL0 asNumber
        if(kStiffness != nil, d stiffness = kStiffness asNumber)
        if(cDamping != nil, d damping = cDamping asNumber)
        d isBroken = false
        d currentTension = 0.0
        d isSlack = false
        d extensionHistory = List clone
        d
    )

    // Computes dynamic force exerted by dropper on contact wire (positive downwards)
    // yMessenger: vertical position of messenger wire at this x
    // yContact: vertical position of contact wire at this x
    // vMessenger: vertical velocity of messenger wire
    // vContact: vertical velocity of contact wire
    computeForce := method(yMessenger, yContact, vMessenger, vContact,
        if(self isBroken,
            self currentTension = 0.0
            self isSlack = true
            return 0.0
        )

        // Instantaneous distance between messenger wire and contact wire:
        // Delta = (yMessenger - yContact) - L0
        deltaL := (yMessenger - yContact) - (self nominalLength)
        deltaV := vMessenger - vContact

        if(deltaL > 0.0,
            // Dropper in tension (stretched): linear spring + damper
            fTension := (self stiffness * deltaL) + (self damping * deltaV)
            if(fTension < 0.0, fTension = 0.0) // prevent numerical compression suction
            self currentTension = fTension
            self isSlack = false
            fTension,
            // Dropper compressed: slackened wire offers zero compressive resistance
            self currentTension = 0.0
            self isSlack = true
            0.0
        )
    )

    // Snaps the dropper during dynamic simulation (structural fault injection)
    breakDropper := method(
        self isBroken = true
        self currentTension = 0.0
        self isSlack = true
        self
    )
)
