// ThermalOverload49.io
// ANSI 49 conductor thermal overload replica relay based on IEEE 738 dynamic heat balance.

ThermalOverload49 := Object clone do(
    id := "RELAY-49"
    nominalCurrentA := 800.0   // Rated continuous current I_nom [A]
    warningTempC := 85.0       // Warning alarm temperature [deg C]
    tripTempC := 100.0         // Emergency trip temperature [deg C] (max allowable for CuAg)

    // Conductor thermal properties (for 120 mm^2 CuAg contact wire)
    conductorResistance20 := 0.15 // Ohm / km at 20 deg C
    alphaResistance := 0.0039     // 1 / K temperature coefficient
    thermalMassCp := 420.0        // Specific heat * mass [J / (m * K)]
    outerDiameterM := 0.0125      // 12.5 mm contact wire outer diameter

    // Dynamic temperature state
    conductorTempC := 25.0        // Instantaneous conductor temperature [deg C]
    ambientTempC := 25.0          // Ambient air temperature [deg C]
    isAlarm := false
    isTripped := false

    setupRelay := method(relayId, inomA, warnC, tripC, r20,
        t := self clone
        if(relayId != nil, t id = relayId)
        if(inomA != nil, t nominalCurrentA = inomA asNumber)
        if(warnC != nil, t warningTempC = warnC asNumber)
        if(tripC != nil, t tripTempC = tripC asNumber)
        if(r20 != nil, t conductorResistance20 = r20 asNumber)
        t conductorTempC = 25.0
        t ambientTempC = 25.0
        t isAlarm = false
        t isTripped = false
        t
    )

    // Advances conductor heat balance over time step dt [s]:
    // currentA: instantaneous current [A]
    // ambientC: ambient temperature [deg C]
    // windSpeedMs: crosswind velocity [m/s]
    stepThermal := method(dt, currentA, ambientC, windSpeedMs,
        if(ambientC != nil, self ambientTempC = ambientC)
        if(windSpeedMs == nil or windSpeedMs < 0.2, windSpeedMs = 0.5) // minimum natural convection

        // 1. Temperature-dependent electrical resistance: R(T) = R20 * (1 + alpha * (T - 20))
        rPerMeter := ((self conductorResistance20) / 1000.0) * (1.0 + (self alphaResistance * (self conductorTempC - 20.0)))

        // 2. Joule heating per meter: q_j = I^2 * R [W / m]
        qJoule := (currentA squared) * rPerMeter

        // 3. Solar heating per meter (assumed standard sunny day 800 W/m^2):
        // q_s = alpha_absorb * Q_solar * D = 0.8 * 800 * 0.0125 ~ 8 W/m
        qSolar := 8.0

        // 4. Convective cooling per IEEE 738:
        // q_c ~ h_conv * pi * D * (T_c - T_amb)
        // h_conv ~ 10.0 + 8.0 * (v_wind ^ 0.6)
        hConv := 10.0 + (8.0 * (windSpeedMs pow(0.6)))
        deltaT := (self conductorTempC) - (self ambientTempC)
        qConv := hConv * (Number constants pi) * (self outerDiameterM) * deltaT

        // 5. Radiative cooling per Stefan-Boltzmann:
        // q_r ~ epsilon * sigma * pi * D * ((T_c+273)^4 - (T_amb+273)^4)
        sigmaB := 5.670374e-8
        tAbsC := self conductorTempC + 273.15
        tAbsA := self ambientTempC + 273.15
        qRad := 0.8 * sigmaB * (Number constants pi) * (self outerDiameterM) * ((tAbsC pow(4)) - (tAbsA pow(4)))

        // Net heat flow: q_net = q_j + q_s - q_c - q_r [W / m]
        qNet := qJoule + qSolar - qConv - qRad

        // Temperature rate of change: dT/dt = q_net / thermalMassCp
        dT := (qNet / (self thermalMassCp)) * dt
        self conductorTempC = self conductorTempC + dT

        // Check alarm and trip thresholds
        self isAlarm = (self conductorTempC >= self warningTempC)
        self isTripped = (self conductorTempC >= self tripTempC)

        self conductorTempC
    )
)
