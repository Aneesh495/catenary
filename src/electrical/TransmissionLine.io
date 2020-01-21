// TransmissionLine.io
// Multi-conductor Carson-Clem coupled transmission line impedance model for 2x25 kV electrification.

doFile("src/math/Complex.io")

TransmissionLine := Object clone do(
    frequency := 50.0         // System frequency [Hz] (50 or 60 Hz)
    earthResistivity := 100.0 // Earth resistivity rho [Ohm * m] (typically 100 Ohm*m)

    setupGrid := method(gridFreqHz, rhoEarth,
        tl := self clone
        if(gridFreqHz != nil, tl frequency = gridFreqHz asNumber)
        if(rhoEarth != nil, tl earthResistivity = rhoEarth asNumber)
        tl
    )

    // Equivalent depth of earth return path per Carson-Clem:
    // De = 658 * sqrt(rho / f) [m]
    earthReturnDepth := method(
        658.0 * (((self earthResistivity) / (self frequency)) sqrt)
    )

    // Self-impedance of a single conductor with earth return [Ohm / km]:
    // Z_ii = r_c + pi^2 * f * 1e-4 + j * 4 * pi * f * 1e-4 * ln(De / r_equiv)
    selfImpedancePerKm := method(conductorResistanceOhmPerKm, geometricMeanRadiusM,
        f := self frequency
        de := self earthReturnDepth

        // Carson earth resistance correction: deltaR = pi^2 * f * 1e-4 [Ohm / km]
        rEarth := (Number constants pi squared) * f * 1e-4
        rTotal := conductorResistanceOhmPerKm + rEarth

        // Inductive reactance: X_ii = 4 * pi * f * 1e-4 * ln(De / GMR) [Ohm / km]
        xTotal := 4.0 * (Number constants pi) * f * 1e-4 * ((de / geometricMeanRadiusM) log)

        Complex with(rTotal, xTotal)
    )

    // Mutual impedance between conductors i and j with earth return [Ohm / km]:
    // Z_ij = pi^2 * f * 1e-4 + j * 4 * pi * f * 1e-4 * ln(De / D_ij)
    mutualImpedancePerKm := method(distanceM,
        if(distanceM <= 0.0, Exception raise("Distance between conductors must be positive"))
        f := self frequency
        de := self earthReturnDepth

        rMutual := (Number constants pi squared) * f * 1e-4
        xMutual := 4.0 * (Number constants pi) * f * 1e-4 * ((de / distanceM) log)

        Complex with(rMutual, xMutual)
    )

    // Standard high-speed 2x25 kV loop impedance per km between Catenary and Rail:
    // Typical value: ~0.15 + j0.40 Ohm/km
    standardCatenaryRailImpedancePerKm := method(
        Complex with(0.165, 0.420)
    )

    // Standard Feeder to Rail loop impedance per km:
    standardFeederRailImpedancePerKm := method(
        Complex with(0.180, 0.440)
    )
)
