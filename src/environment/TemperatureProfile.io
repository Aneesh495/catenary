// TemperatureProfile.io
// Diurnal ambient temperature cycles and thermal expansion sag calculation.

TemperatureProfile := Object clone do(
    minDailyTempC := 12.0     // Night-time minimum temperature [deg C]
    maxDailyTempC := 36.0     // Afternoon peak temperature [deg C]
    peakHour := 14.0          // Time of peak temperature (14:00 hours)
    cyclePeriodHours := 24.0

    setupProfile := method(minC, maxC, peakHr,
        tp := self clone
        if(minC != nil, tp minDailyTempC = minC asNumber)
        if(maxC != nil, tp maxDailyTempC = maxC asNumber)
        if(peakHr != nil, tp peakHour = peakHr asNumber)
        tp
    )

    // Ambient temperature at time t in hours (0.0 to 24.0) via sinusoidal diurnal model:
    // T(t) = T_mean + T_amplitude * cos(2 * pi * (t - peakHour) / 24)
    ambientTemperatureAtHour := method(hour,
        meanT := ((self minDailyTempC) + (self maxDailyTempC)) * 0.5
        ampT := ((self maxDailyTempC) - (self minDailyTempC)) * 0.5
        phase := 2.0 * (Number constants pi) * (hour - (self peakHour)) / (self cyclePeriodHours)
        meanT + (ampT * (phase cos))
    )

    // Ambient temperature at time t in seconds:
    ambientTemperatureAtSecond := method(seconds,
        hours := (seconds / 3600.0) % 24.0
        self ambientTemperatureAtHour(hours)
    )
)
