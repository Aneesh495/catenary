// CatenarySystem.io
// Multi-span continuous overhead catenary system assembly and structural solver.

doFile("src/mechanics/Material.io")
doFile("src/mechanics/ContactWire.io")
doFile("src/mechanics/MessengerWire.io")
doFile("src/mechanics/Dropper.io")
doFile("src/mechanics/RegistrationArm.io")
doFile("src/mechanics/StitchWire.io")
doFile("src/mechanics/Tensioner.io")
doFile("src/mechanics/Span.io")
doFile("src/math/Vector.io")
doFile("src/math/Matrix.io")
doFile("src/math/SparseMatrix.io")

CatenarySystem := Object clone do(
    totalLength := 0.0
    spans := nil
    contactWire := nil
    messengerWire := nil
    droppers := nil
    registrationArms := nil
    stitchWires := nil
    tensioner := nil

    // Structural damping coefficients (Rayleigh damping: C = alpha * M + beta * K)
    rayleighAlpha := 0.125
    rayleighBeta := 0.00015

    setupStandardSystem := method(numSpans, spanLength,
        if(numSpans == nil, numSpans = 10)
        if(spanLength == nil, spanLength = 55.0)

        cs := self clone
        cs totalLength = numSpans * spanLength
        cs spans = List clone
        cs droppers = List clone
        cs registrationArms = List clone
        cs stitchWires = List clone

        // 1. Create Spans and steady arms
        curX := 0.0
        for(sIdx, 0, numSpans - 1,
            spanObj := Span clone setupSpan(sIdx, curX, spanLength, 0.0, nil)
            cs spans append(spanObj)

            // Alternating stagger at each mast: +/- 0.20 m
            staggerSign := if(sIdx % 2 == 0, 1.0, -1.0)
            arm := RegistrationArm clone setupArm(sIdx, curX, 0.20 * staggerSign, 1.10, 1.20, 0.12)
            cs registrationArms append(arm)

            curX = curX + spanLength
        )
        // Last mast registration arm
        lastArm := RegistrationArm clone setupArm(numSpans, curX, -0.20, 1.10, 1.20, 0.12)
        cs registrationArms append(lastArm)

        // 2. Setup Contact Wire (CuAg0.1, 120 mm^2, 25 kN)
        // Discretisation: ~0.5m element length
        contactNodes := ((cs totalLength) * 2.0 + 1) round
        matContact := Material CuAg01
        cs contactWire = ContactWire clone setupDiscretised(matContact, 120e-6, 25000.0, cs totalLength, contactNodes, 5.30)

        // 3. Setup Messenger Wire (Bz-II, 65 mm^2, 18 kN)
        matMessenger := Material BronzeII
        cs messengerWire = MessengerWire clone setupDiscretised(matMessenger, 65e-6, 18000.0, cs totalLength, contactNodes, 6.50, 0.75)

        // 4. Setup Droppers at specified relative positions in each span
        dropperId := 1
        cs spans foreach(s,
            s dropperSpacing foreach(relX,
                dropX := (s startX) + relX
                // Initial nominal length matches distance between static messenger sag and contact wire
                nomLen := 1.20 - (cs messengerWire staticSagAt(relX, s length))
                d := Dropper clone setupDropper(dropperId, dropX, nomLen, 2.5e4, 50.0)
                cs droppers append(d)
                dropperId = dropperId + 1
            )
        )

        // 5. Setup Tensioner (3:1 ratio, 850 kg counterweight)
        cs tensioner = Tensioner clone setupTensioner(850.0, 3.0, 0.02, 1.20, 20.0)
        cs
    )

    // Computes all dropper forces acting between messenger wire and contact wire
    // Returns List of forces corresponding to each dropper
    computeAllDropperForces := method(
        forces := List clone
        self droppers foreach(d,
            yMess := (self messengerWire nominalSupportHeight) + (self messengerWire interpolatedDisplacementAt(d xPosition))
            yCont := (self contactWire nominalHeight) + (self contactWire interpolatedDisplacementAt(d xPosition))
            vMess := 0.0 // dynamic velocity can be passed
            vCont := 0.0
            f := d computeForce(yMess, yCont, vMess, vCont)
            forces append(f)
        )
        forces
    )

    // Applies external pantograph upward contact force F_contact at position x
    // Solves 1 time-step update for contact wire and messenger wire
    stepDynamics := method(dt, pantographX, pantographForce)
)
