// FaultLocator.io
// Fault location estimation via line reactance and high-frequency traveling wave timing.

FaultLocator := Object clone do(
    substationKm := 0.0
    reactancePerKm := 0.420    // Loop reactance [Ohm / km]
    waveVelocityKmh := 294000.0 // Electromagnetic pulse propagation speed ~0.98 * c_light [km/s]

    setupLocator := method(subKm, xPerKm, vPulseKms,
        fl := self clone
        if(subKm != nil, fl substationKm = subKm asNumber)
        if(xPerKm != nil, fl reactancePerKm = xPerKm asNumber)
        if(vPulseKms != nil, fl waveVelocityKmh = vPulseKms asNumber)
        fl
    )

    // Method 1: Apparent reactance method
    // d_fault = X_measured / X_per_km [km from substation]
    estimateDistanceByReactance := method(measuredReactanceOhm,
        if(self reactancePerKm <= 0.0, return 0.0)
        distFromSub := measuredReactanceOhm / (self reactancePerKm)
        (self substationKm) + distFromSub
    )

    // Method 2: High-frequency traveling wave arrival time difference:
    // d_fault = v_wave * (t_arrival - t_zero)
    estimateDistanceByWave := method(travelTimeMicroseconds,
        timeSeconds := travelTimeMicroseconds * 1e-6
        distKm := 294000.0 * timeSeconds
        (self substationKm) + distKm
    )
)
