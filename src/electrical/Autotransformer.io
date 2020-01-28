// Autotransformer.io
// 50 kV / 25 kV center-tapped autotransformer (AT) station model.

doFile("src/math/Complex.io")

Autotransformer := Object clone do(
    id := "AT-1"
    trackLocationKm := 10.0   // Location along railway corridor [km]
    ratedPowerMVA := 10.0     // Nominal power rating [MVA] (typically 10-15 MVA per AT station)
    leakageReactancePercent := 1.20 // Short-circuit leakage impedance Uk% (typically 1.0 - 1.5%)
    magnetizingCurrentPercent := 0.50 // No-load excitation current I0%

    // Dynamic currents in windings
    catenaryWindingCurrentA := 0.0
    feederWindingCurrentA := 0.0
    neutralRailCurrentA := 0.0 // I_rail = I_catenary - I_feeder

    setupAT := method(atId, kmPos, mvaRating, ukPercent,
        at := self clone
        if(atId != nil, at id = atId)
        if(kmPos != nil, at trackLocationKm = kmPos asNumber)
        if(mvaRating != nil, at ratedPowerMVA = mvaRating asNumber)
        if(ukPercent != nil, at leakageReactancePercent = ukPercent asNumber)
        at catenaryWindingCurrentA = 0.0
        at feederWindingCurrentA = 0.0
        at neutralRailCurrentA = 0.0
        at
    )

    // Leakage impedance referred to 25 kV winding [Ohm]:
    // Z_at = (Uk% / 100) * (V_nom^2 / S_nom)
    leakageImpedance := method(
        vNom := 27500.0
        sNomVA := (self ratedPowerMVA) * 1e6
        zBase := (vNom squared) / sNomVA
        xLeak := ((self leakageReactancePercent) / 100.0) * zBase
        rLeak := 0.05 * xLeak
        Complex with(rLeak, xLeak)
    )

    // Current balancing division between catenary and feeder for a train at distance x:
    // In an ideal AT section of length D between two AT stations,
    // a train load current I_train is split such that approximately:
    // I_catenary = I_train * (1 - x / (2*D))
    // I_feeder = I_train * (x / (2*D))
    // Thus rail current is reduced to only localized circulation between adjacent ATs!
    computeWindingCurrents := method(trainCurrentA, distanceToTrainKm, sectionLengthKm,
        if(sectionLengthKm <= 0.0, sectionLengthKm = 10.0)
        normDist := distanceToTrainKm / sectionLengthKm
        if(normDist > 1.0, normDist = 1.0)
        if(normDist < 0.0, normDist = 0.0)

        // Balanced 2x25 kV AT current distribution:
        self catenaryWindingCurrentA = trainCurrentA * (1.0 - (normDist * 0.5))
        self feederWindingCurrentA = trainCurrentA * (normDist * 0.5)
        self neutralRailCurrentA = (self catenaryWindingCurrentA) - (self feederWindingCurrentA)
        list(self catenaryWindingCurrentA, self feederWindingCurrentA, self neutralRailCurrentA)
    )
)
