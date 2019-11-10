// Statistics.io
// Statistical analysis and digital filtering for railway dynamics standards compliance.

Statistics := Object clone do(
    mean := method(valList,
        n := valList size
        if(n == 0, return 0.0)
        sum := 0.0
        valList foreach(v, sum = sum + v)
        sum / n
    )

    variance := method(valList,
        n := valList size
        if(n <= 1, return 0.0)
        m := self mean(valList)
        sumSq := 0.0
        valList foreach(v, sumSq = sumSq + ((v - m) squared))
        sumSq / (n - 1)
    )

    standardDeviation := method(valList,
        (self variance(valList)) sqrt
    )

    min := method(valList,
        if(valList size == 0, return 0.0)
        m := valList at(0)
        valList foreach(v, if(v < m, m = v))
        m
    )

    max := method(valList,
        if(valList size == 0, return 0.0)
        m := valList at(0)
        valList foreach(v, if(v > m, m = v))
        m
    )

    // Statistical extreme values per EN 50318 / EN 50367
    // F_max_stat = F_m + 3 * sigma
    // F_min_stat = F_m - 3 * sigma
    statisticalMax := method(valList,
        m := self mean(valList)
        s := self standardDeviation(valList)
        m + (3.0 * s)
    )

    statisticalMin := method(valList,
        m := self mean(valList)
        s := self standardDeviation(valList)
        m - (3.0 * s)
    )

    // Contact loss percentage: NQ = (sum(t_arc) / total_time) * 100%
    // Contact loss is registered when contact force drops to 0 or below threshold (e.g. 5 N)
    contactLossPercentage := method(forceList, threshold,
        if(threshold == nil, threshold = 5.0)
        n := forceList size
        if(n == 0, return 0.0)
        lossCount := 0
        forceList foreach(f,
            if(f <= threshold, lossCount = lossCount + 1)
        )
        (lossCount / n) * 100.0
    )

    // 1st order digital Butterworth-style low-pass filter (cutoff frequency fc, sample rate fs)
    lowPassFilter := method(rawList, cutoffHz, sampleRateHz,
        n := rawList size
        if(n == 0, return List clone)
        rc := 1.0 / (2.0 * (Number constants pi) * cutoffHz)
        dt := 1.0 / sampleRateHz
        alpha := dt / (rc + dt)

        filtered := List clone
        prev := rawList at(0)
        filtered append(prev)

        for(i, 1, n - 1,
            curr := (alpha * (rawList at(i))) + ((1.0 - alpha) * prev)
            filtered append(curr)
            prev = curr
        )
        filtered
    )
)
