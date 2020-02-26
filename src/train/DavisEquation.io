// DavisEquation.io
// Davis equation for high-speed rolling stock resistance: R(v) = A + B*v + C*v^2.

DavisEquation := Object clone do(
    coeffA := 2500.0          // Mechanical rolling resistance [N]
    coeffB := 45.0            // Flange and mechanical velocity resistance [N / (m/s)]
    coeffC := 3.20            // Aerodynamic drag coefficient [N / (m/s)^2]

    setupCoefficients := method(aN, bNs, cNs2,
        d := self clone
        if(aN != nil, d coeffA = aN asNumber)
        if(bNs != nil, d coeffB = bNs asNumber)
        if(cNs2 != nil, d coeffC = cNs2 asNumber)
        d
    )

    // Standard high-speed 8-car trainset (e.g. ICE 3 / Shinkansen E5 / TGV Duplex)
    // Mass ~ 450 tonnes, length 200 m
    HighSpeedTrainset := method(
        self setupCoefficients(3200.0, 60.0, 4.10)
    )

    // Computes total resistance force R [N] at velocity v [m/s]
    resistanceAtVelocityMs := method(vMs,
        v := vMs abs
        (self coeffA) + ((self coeffB) * v) + ((self coeffC) * (v squared))
    )

    // Resistance in kN at velocity in km/h
    resistanceAtVelocityKmh := method(vKmh,
        vMs := vKmh / 3.6
        (self resistanceAtVelocityMs(vMs)) / 1000.0
    )
)
