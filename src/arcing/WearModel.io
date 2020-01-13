// WearModel.io
// Combined mechanical abrasive wear (Archard) and electrical arc erosion model.

WearModel := Object clone do(
    // Material hardness and Archard wear coefficients
    // Hardness of carbon collector strip: H ~ 6.0e8 Pa
    stripHardness := 6.0e8
    archardWearCoeff := 2.5e-5 // Dimensionless Archard coefficient k_w

    // Electrical erosion coefficient: k_e [m^3 / (A^1.5 * s)]
    electricalErosionCoeff := 1.8e-11

    // Cumulative wear tracking
    cumulativeMechanicalVolume := 0.0 // m^3
    cumulativeElectricalVolume := 0.0 // m^3
    totalWearVolume := 0.0            // m^3

    setupWear := method(hardnessPa, kArchard, kElec,
        w := self clone
        if(hardnessPa != nil, w stripHardness = hardnessPa asNumber)
        if(kArchard != nil, w archardWearCoeff = kArchard asNumber)
        if(kElec != nil, w electricalErosionCoeff = kElec asNumber)
        w cumulativeMechanicalVolume = 0.0
        w cumulativeElectricalVolume = 0.0
        w totalWearVolume = 0.0
        w
    )

    // Computes incremental wear rate over time step dt:
    // contactForce: normal force [N]
    // slidingVelocity: train speed [m/s]
    // isArcing: boolean flag indicating active electric arc
    // arcCurrent: current through arc [A]
    stepWear := method(dt, contactForce, slidingVelocity, isArcing, arcCurrent,
        slidingDistance := slidingVelocity * dt

        // 1. Archard mechanical abrasive wear:
        // V_mech = (k_w * F_n * s) / H
        incrementalMech := 0.0
        if(contactForce > 0.0,
            incrementalMech = ((self archardWearCoeff) * contactForce * slidingDistance) / (self stripHardness)
            self cumulativeMechanicalVolume = self cumulativeMechanicalVolume + incrementalMech
        )

        // 2. Electrical thermal erosion from plasma arc:
        // V_elec = k_e * I^1.5 * dt (if arcing)
        incrementalElec := 0.0
        if(isArcing and arcCurrent > 0.0,
            incrementalElec = (self electricalErosionCoeff) * (arcCurrent pow(1.5)) * dt
            self cumulativeElectricalVolume = self cumulativeElectricalVolume + incrementalElec
        )

        self totalWearVolume = (self cumulativeMechanicalVolume) + (self cumulativeElectricalVolume)
        list(incrementalMech, incrementalElec)
    )

    // Residual contact strip thickness remaining given initial thickness [m]
    // stripWidth: 0.03 m, stripLength: 1.0 m
    residualThickness := method(initialThicknessM, stripAreaM2,
        if(stripAreaM2 == nil, stripAreaM2 = 0.03) // 30mm width * 1m length
        wearDepth := self totalWearVolume / stripAreaM2
        res := initialThicknessM - wearDepth
        if(res < 0.0, 0.0, res)
    )
)
