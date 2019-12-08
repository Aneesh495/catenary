// Tensioner.io
// Auto-tensioning pulley and counterweight balance model for thermal expansion regulation.

Tensioner := Object clone do(
    counterweightMass := 650.0  // kg
    pulleyRatio := 3.0          // Mechanical advantage (e.g. 3:1 or 4:1)
    gravity := 9.80665          // m / s^2
    pulleyFrictionCoefficient := 0.02 // Internal bearing friction
    counterweightTravelLimit := 1.20  // Maximum travel stroke [m]
    referenceTemperature := 20.0      // deg C

    setupTensioner := method(cwMassKg, ratio, friction, maxTravelM, refTempC,
        t := self clone
        if(cwMassKg != nil, t counterweightMass = cwMassKg asNumber)
        if(ratio != nil, t pulleyRatio = ratio asNumber)
        if(friction != nil, t pulleyFrictionCoefficient = friction asNumber)
        if(maxTravelM != nil, t counterweightTravelLimit = maxTravelM asNumber)
        if(refTempC != nil, t referenceTemperature = refTempC asNumber)
        t
    )

    // Ideal regulated nominal wire tension: T_nom = M_cw * g * ratio
    nominalTension := method(
        (self counterweightMass) * (self gravity) * (self pulleyRatio)
    )

    // Dynamic tension accounting for motion friction (plus/minus depending on motion direction)
    effectiveTension := method(movingDirection,
        // movingDirection: +1 expanding, -1 contracting, 0 stationary
        tNom := self nominalTension
        fLoss := tNom * (self pulleyFrictionCoefficient) * movingDirection
        tNom - fLoss
    )

    // Computes counterweight vertical displacement for given thermal deltaL:
    // delta_h = deltaL * ratio
    counterweightDisplacement := method(deltaL,
        deltaL * (self pulleyRatio)
    )

    // Checks if counterweight has hit physical upper/lower travel limit stops
    isAtTravelLimit := method(deltaL,
        disp := (self counterweightDisplacement(deltaL)) abs
        disp >= self counterweightTravelLimit
    )
)
