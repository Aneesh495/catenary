// WindModel.io
// Turbulent aerodynamic wind field, gust generation, and lateral wire blow-off displacement.

WindModel := Object clone do(
    meanWindSpeedMs := 5.0     // Mean crosswind speed [m/s]
    gustAmplitudeMs := 3.0     // Gust turbulent deviation amplitude [m/s]
    crosswindAngleDeg := 90.0  // Wind angle relative to track alignment (90 deg = pure crosswind)
    airDensity := 1.225        // kg / m^3
    dragCoefficient := 1.10    // Drag coefficient for circular wire in crossflow

    setupWind := method(meanMs, gustMs, angleDeg,
        w := self clone
        if(meanMs != nil, w meanWindSpeedMs = meanMs asNumber)
        if(gustMs != nil, w gustAmplitudeMs = gustMs asNumber)
        if(angleDeg != nil, w crosswindAngleDeg = angleDeg asNumber)
        w
    )

    // Computes instantaneous wind speed including sinusoidal/turbulent gust component at time t:
    instantaneousWindSpeed := method(t,
        gust := (self gustAmplitudeMs) * ((2.0 * (Number constants pi) * 0.2 * t) sin)
        speed := (self meanWindSpeedMs) + gust
        if(speed < 0.0, 0.0, speed)
    )

    // Aerodynamic lateral drag force per unit length [N / m] on wire of diameter D [m]:
    // q_drag = 0.5 * rho * Cd * D * (V_w * sin(theta))^2
    lateralDragPerMeter := method(t, wireDiameterM,
        vw := self instantaneousWindSpeed(t)
        thetaRad := (self crosswindAngleDeg) * (Number constants pi) / 180.0
        vCross := vw * (thetaRad sin abs)
        0.5 * (self airDensity) * (self dragCoefficient) * wireDiameterM * (vCross squared)
    )

    // Lateral wire blow-off displacement at midspan of span length L [m] under tension T [N]:
    // b_mid = (q_drag * L^2) / (8 * T)
    midspanBlowOffDisplacement := method(t, wireDiameterM, spanLengthM, tensionN,
        qDrag := self lateralDragPerMeter(t, wireDiameterM)
        if(tensionN <= 0.0, return 0.0)
        (qDrag * (spanLengthM squared)) / (8.0 * tensionN)
    )
)
