// ContactForce.io
// Unilateral non-linear contact mechanics between pantograph head and contact wire.

ContactForce := Object clone do(
    contactStiffness := 5.0e4 // Contact patch stiffness k_c [N / m] (typically 50,000 N/m)
    contactDamping := 100.0   // Contact damping c_c [N * s / m]
    frictionCoefficient := 0.15 // Carbon strip on copper wire dry friction coefficient

    setupContact := method(kContact, cContact, muFriction,
        cf := self clone
        if(kContact != nil, cf contactStiffness = kContact asNumber)
        if(cContact != nil, cf contactDamping = cContact asNumber)
        if(muFriction != nil, cf frictionCoefficient = muFriction asNumber)
        cf
    )

    // Computes normal contact force F_c:
    // yPanto: absolute height of pantograph head
    // yWire: absolute height of contact wire at pantograph x position
    // vPanto: vertical velocity of pantograph head
    // vWire: vertical velocity of contact wire
    computeNormalForce := method(yPanto, yWire, vPanto, vWire,
        penetration := yPanto - yWire
        relVelocity := vPanto - vWire

        if(penetration > 0.0,
            // Penetration / active contact: spring + damping
            fn := (self contactStiffness * penetration) + (self contactDamping * relVelocity)
            if(fn < 0.0, fn = 0.0) // unilateral contact constraint (cannot pull wire downwards)
            fn,
            // Contact loss / separation: gap between head and wire
            0.0
        )
    )

    // Tangential longitudinal friction force: F_friction = mu * F_normal
    computeLongitudinalFriction := method(normalForce,
        (self frictionCoefficient) * normalForce
    )

    // Lateral contact location across carbon collector strip:
    // Depends directly on catenary zig-zag stagger z(x)
    lateralContactPosition := method(staggerZ,
        // Carbon strip active width is typically +/- 400 mm
        staggerZ
    )
)
