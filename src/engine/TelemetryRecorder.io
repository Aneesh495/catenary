// TelemetryRecorder.io
// High-throughput time-series telemetry recorder with CSV and JSON export facilities.

TelemetryRecorder := Object clone do(
    sampleRateHz := 1000.0    // Logging sample rate [Hz]
    timeHistory := nil
    pantographXHistory := nil
    pantographHeightHistory := nil
    contactForceHistory := nil
    catenaryVoltageHistory := nil
    tractionPowerHistory := nil
    isArcingHistory := nil

    setupRecorder := method(rateHz,
        r := self clone
        if(rateHz != nil, r sampleRateHz = rateHz asNumber)
        r timeHistory = List clone
        r pantographXHistory = List clone
        r pantographHeightHistory = List clone
        r contactForceHistory = List clone
        r catenaryVoltageHistory = List clone
        r tractionPowerHistory = List clone
        r isArcingHistory = List clone
        r
    )

    recordSample := method(t, xPanto, yPanto, fContact, vCatenary, pTraction, isArcing,
        self timeHistory append(t asNumber)
        self pantographXHistory append(xPanto asNumber)
        self pantographHeightHistory append(yPanto asNumber)
        self contactForceHistory append(fContact asNumber)
        self catenaryVoltageHistory append(vCatenary asNumber)
        self tractionPowerHistory append(pTraction asNumber)
        self isArcingHistory append(if(isArcing, 1, 0))
        self
    )

    sampleCount := method(
        self timeHistory size
    )

    // Export telemetry buffer to CSV file at filePath
    exportCSV := method(filePath,
        f := File with(filePath)
        f openForUpdating
        f write("time_s,panto_x_m,panto_height_m,contact_force_n,catenary_voltage_v,traction_power_mw,is_arcing\n")
        n := self sampleCount
        for(i, 0, n - 1,
            line := (self timeHistory at(i) asString) .. "," ..
                   (self pantographXHistory at(i) asString) .. "," ..
                   (self pantographHeightHistory at(i) asString) .. "," ..
                   (self contactForceHistory at(i) asString) .. "," ..
                   (self catenaryVoltageHistory at(i) asString) .. "," ..
                   (self tractionPowerHistory at(i) asString) .. "," ..
                   (self isArcingHistory at(i) asString) .. "\n"
            f write(line)
        )
        f close
        self
    )
)
