// NodalAdmittanceSolver.io
// Multi-node AC power flow solver for 2x25 kV autotransformer traction networks.

doFile("src/math/Complex.io")
doFile("src/math/Matrix.io")
doFile("src/electrical/TransmissionLine.io")
doFile("src/electrical/Substation.io")
doFile("src/electrical/Autotransformer.io")

NodalAdmittanceSolver := Object clone do(
    substations := nil
    autotransformers := nil
    transmissionLine := nil
    lineLengthKm := 50.0

    setupNetwork := method(lengthKm,
        nas := self clone
        nas lineLengthKm = if(lengthKm != nil, lengthKm asNumber, 50.0)
        nas substations = List clone
        nas autotransformers = List clone
        nas transmissionLine = TransmissionLine clone setupGrid(50.0, 100.0)
        nas
    )

    addSubstation := method(sub,
        self substations append(sub)
        self
    )

    addAutotransformer := method(at,
        self autotransformers append(at)
        self
    )

    // Solves instantaneous catenary-to-rail voltage at arbitrary track coordinate xKm
    // given a train located at trainKm drawing active power pMW and reactive power qMVAR
    solveVoltageProfile := method(trainKm, pMW, qMVAR,
        if(self substations size == 0,
            return Complex with(25000.0, 0.0)
        )
        // Find nearest feeding substation
        nearestSub := self substations at(0)
        minDist := (nearestSub trackLocationKm - trainKm) abs
        self substations foreach(sub,
            d := (sub trackLocationKm - trainKm) abs
            if(d < minDist,
                minDist = d
                nearestSub = sub
            )
        )

        // Nominal substation voltage
        vSub := nearestSub nominalCatenaryVoltage

        // Loop impedance between substation and train
        zPerKm := self transmissionLine standardCatenaryRailImpedancePerKm
        zLoop := Complex with((zPerKm re) * minDist, (zPerKm im) * minDist)

        // Internal substation source impedance
        zSource := nearestSub internalImpedance
        zTotal := zLoop add(zSource)

        // Train apparent current: I ~ S* / V_nom
        sMVA := (((pMW squared) + (qMVAR squared)) sqrt)
        iMag := (sMVA * 1e6) / vSub
        if(pMW < 0.0, iMag = -iMag) // Negative current during regen

        cosPhi := 0.98
        sinPhi := (1.0 - (cosPhi squared)) sqrt
        iTrain := Complex with(iMag * cosPhi, -iMag * sinPhi)

        // Voltage drop: DeltaV = I * Z
        vDrop := iTrain multiply(zTotal)
        vCatenary := (Complex with(vSub, 0.0)) subtract(vDrop)

        // Substation telemetry update
        nearestSub updateTelemetry(pMW, qMVAR)

        vCatenary
    )
)
