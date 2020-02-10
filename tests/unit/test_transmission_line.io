// test_transmission_line.io
// Unit verification for Carson-Clem multi-conductor line impedance calculations.

doFile("src/electrical/TransmissionLine.io")

assertions := 0

assert := method(cond, desc,
    assertions = assertions + 1
    if(cond not,
        Exception raise("Assertion failure in test_transmission_line: " .. desc)
    )
)

tl := TransmissionLine clone setupGrid(50.0, 100.0)

assert(tl frequency == 50.0, "System frequency 50 Hz")
assert(tl earthResistivity == 100.0, "Earth resistivity 100 Ohm*m")

// Carson earth return depth De = 658 * sqrt(100 / 50) = 658 * sqrt(2) ~ 930.55 m
de := tl earthReturnDepth
assert((de - 930.55) abs < 1.0, "Carson earth return depth ~931 m")

// Conductor with resistance 0.15 Ohm/km, GMR 0.006 m
zSelf := tl selfImpedancePerKm(0.15, 0.006)
assert(zSelf re > 0.15, "Self resistance includes Carson earth correction")
assert(zSelf im > 0.0, "Self inductive reactance positive")

// Mutual impedance across 5m conductor separation
zMutual := tl mutualImpedancePerKm(5.0)
assert(zMutual re > 0.0, "Mutual resistance positive")
assert(zMutual im > 0.0, "Mutual reactance positive")
assert(zMutual im < zSelf im, "Mutual reactance less than self reactance")

// Standard catenary-rail impedance
zCatRail := tl standardCatenaryRailImpedancePerKm
assert(zCatRail re == 0.165, "Standard loop resistance 0.165 Ohm/km")
assert(zCatRail im == 0.420, "Standard loop reactance 0.420 Ohm/km")

("test_transmission_line completed successfully with " .. assertions .. " passing assertions") println
