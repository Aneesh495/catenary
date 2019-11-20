// ConductorWire.io
// Base prototype for tensioned overhead conductors, wave propagation, and thermal expansion.

doFile("src/mechanics/Material.io")

ConductorWire := Object clone do(
    material := nil
    crossSection := 0.0      // m^2 (e.g. 120 mm^2 = 120e-6 m^2)
    nominalTension := 0.0    // N (e.g. 25,000 N = 25 kN)
    currentTension := 0.0    // N (dynamic/temperature adjusted)
    length := 0.0            // m

    setupWire := method(mat, areaM2, tensionN, lenM,
        w := self clone
        w material = mat
        w crossSection = areaM2 asNumber
        w nominalTension = tensionN asNumber
        w currentTension = tensionN asNumber
        w length = lenM asNumber
        w
    )

    // Linear mass density: mu = rho * A [kg / m]
    linearMass := method(
        (self material density) * (self crossSection)
    )

    // Transverse wave propagation velocity: c = sqrt(T / mu) [m / s]
    waveVelocity := method(
        mu := self linearMass
        if(mu <= 0.0, Exception raise("Linear mass must be positive for wave velocity"))
        ((self currentTension) / mu) sqrt
    )

    // Wave velocity in km/h
    waveVelocityKmh := method(
        (self waveVelocity) * 3.6
    )

    // Critical train speed limit per EN 50119 (typically 70% of wave velocity)
    maxRecommendedOperatingSpeedKmh := method(
        (self waveVelocityKmh) * 0.70
    )

    // Doppler factor for train running at speed v [m/s]
    dopplerFactor := method(trainVelocityMs,
        c := self waveVelocity
        if(trainVelocityMs >= c,
            Exception raise("Train speed exceeds critical wave velocity of contact line")
        )
        1.0 / (1.0 - (trainVelocityMs / c))
    )

    // Thermal expansion length change: deltaL = L * alpha * deltaT
    thermalExpansionDeltaL := method(deltaT,
        (self length) * (self material thermalExpansion) * deltaT
    )

    // Second moment of area for circular wire: I = (pi / 4) * r^4
    momentOfInertia := method(
        r := ((self crossSection) / (Number constants pi)) sqrt
        (Number constants pi * (r pow(4))) / 4.0
    )

    // Flexural bending stiffness: EI [N * m^2]
    bendingStiffness := method(
        (self material youngsModulus) * (self momentOfInertia)
    )
)
