// AerodynamicUplift.io
// Non-linear aerodynamic uplift force curves for high-speed pantographs.

AerodynamicUplift := Object clone do(
    // Aerodynamic uplift coefficients: F_aero(v) = a0 + a1 * v + a2 * v^2
    // v in m/s, F in Newtons
    // Typical high-speed train pantograph (e.g. WBL 85 / DSA 380):
    // At 300 km/h (83.33 m/s), uplift provides ~40-60 N of aerodynamic lift
    a0 := 0.0
    a1 := 0.12               // N / (m/s)
    a2 := 0.0058             // N / (m/s)^2

    setupCoefficients := method(c0, c1, c2,
        u := self clone
        if(c0 != nil, u a0 = c0 asNumber)
        if(c1 != nil, u a1 = c1 asNumber)
        if(c2 != nil, u a2 = c2 asNumber)
        u
    )

    // Uplift force at speed in m/s
    upliftAtVelocityMs := method(vMs,
        v := vMs abs
        (self a0) + ((self a1) * v) + ((self a2) * (v squared))
    )

    // Uplift force at speed in km/h
    upliftAtVelocityKmh := method(vKmh,
        vMs := vKmh / 3.6
        self upliftAtVelocityMs(vMs)
    )

    // Crosswind correction factor: crosswind increases aerodynamic drag and turbulence
    crosswindUplift := method(vMs, crosswindAngleDeg, crosswindSpeedMs,
        baseUplift := self upliftAtVelocityMs(vMs)
        // Additional lift component from lateral angle of attack
        angleRad := (crosswindAngleDeg asNumber) * (Number constants pi) / 180.0
        crosswindLift := 0.004 * (crosswindSpeedMs squared) * (angleRad sin abs)
        baseUplift + crosswindLift
    )
)
