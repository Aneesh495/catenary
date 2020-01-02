// DualPantograph.io
// Multi-pantograph operation with leading-trailing wave interference dynamics.

doFile("src/pantograph/LumpedMassPantograph.io")
doFile("src/pantograph/AerodynamicUplift.io")
doFile("src/pantograph/ContactForce.io")

DualPantograph := Object clone do(
    spacing := 200.0          // Distance between leading and trailing pantographs [m]
    leadingPantograph := nil
    trailingPantograph := nil
    aeroModel := nil
    contactModel := nil

    setupDual := method(spacingDistanceM, speedKmh, preloadN,
        dp := self clone
        if(spacingDistanceM != nil, dp spacing = spacingDistanceM asNumber)

        vMs := (if(speedKmh != nil, speedKmh, 300.0)) / 3.6
        pLoad := if(preloadN != nil, preloadN, 90.0)

        dp leadingPantograph = LumpedMassPantograph clone setupModel(6.60, 18.00, 7000.0, 40.0, 70.0, pLoad)
        dp leadingPantograph currentVelocity = vMs
        dp leadingPantograph currentX = dp spacing // Leading is ahead at x = D

        dp trailingPantograph = LumpedMassPantograph clone setupModel(6.60, 18.00, 7000.0, 40.0, 70.0, pLoad)
        dp trailingPantograph currentVelocity = vMs
        dp trailingPantograph currentX = 0.0       // Trailing is at x = 0

        dp aeroModel = AerodynamicUplift clone setupCoefficients(0.0, 0.12, 0.0058)
        dp contactModel = ContactForce clone setupContact(50000.0, 100.0, 0.15)
        dp
    )

    // Advances both pantographs simultaneously by time step dt
    stepTime := method(dt, contactWire,
        vMs := self leadingPantograph currentVelocity
        fAero := self aeroModel upliftAtVelocityMs(vMs)

        // Leading pantograph contact
        xLead := self leadingPantograph currentX
        yLeadWire := (contactWire nominalHeight) + (contactWire interpolatedDisplacementAt(xLead))
        yLeadHead := (contactWire nominalHeight) + (self leadingPantograph y1)
        fContactLead := self contactModel computeNormalForce(yLeadHead, yLeadWire, self leadingPantograph v1, 0.0)
        self leadingPantograph stepTime(dt, fContactLead, fAero)

        // Trailing pantograph contact
        xTrail := self trailingPantograph currentX
        yTrailWire := (contactWire nominalHeight) + (contactWire interpolatedDisplacementAt(xTrail))
        yTrailHead := (contactWire nominalHeight) + (self trailingPantograph y1)
        fContactTrail := self contactModel computeNormalForce(yTrailHead, yTrailWire, self trailingPantograph v1, 0.0)
        self trailingPantograph stepTime(dt, fContactTrail, fAero)

        list(fContactLead, fContactTrail)
    )
)
