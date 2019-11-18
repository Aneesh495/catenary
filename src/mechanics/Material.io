// Material.io
// Physical and mechanical properties of overhead catenary conductors and alloys.

Material := Object clone do(
    name := ""
    density := 0.0               // kg / m^3
    youngsModulus := 0.0         // Pa (N / m^2)
    thermalExpansion := 0.0      // 1 / Kelvin (alpha)
    resistivity := 0.0           // Ohm * m at 20 deg C
    temperatureCoefficient := 0.0 // 1 / Kelvin (alpha_R)
    tensileStrength := 0.0       // Pa

    withProps := method(matName, dens, modulus, alphaT, rhoE, alphaR, strength,
        m := self clone
        m name = matName
        m density = dens asNumber
        m youngsModulus = modulus asNumber
        m thermalExpansion = alphaT asNumber
        m resistivity = rhoE asNumber
        m temperatureCoefficient = alphaR asNumber
        m tensileStrength = strength asNumber
        m
    )

    // Standard high-speed railway conductor materials
    // Hard-drawn electrolytic copper (Cu-ETP) for standard lines
    CuETP := method(
        self withProps("Cu-ETP", 8900.0, 1.15e11, 1.7e-5, 1.78e-8, 0.0039, 3.6e8)
    )

    // Silver-copper alloy (CuAg 0.1%) for high-speed contact wires (up to 320 km/h)
    CuAg01 := method(
        self withProps("CuAg0.1", 8910.0, 1.18e11, 1.7e-5, 1.77e-8, 0.0039, 4.2e8)
    )

    // Magnesium-copper alloy (CuMg 0.5%) for ultra-high-speed contact wires (350+ km/h)
    CuMg05 := method(
        self withProps("CuMg0.5", 8890.0, 1.25e11, 1.7e-5, 2.15e-8, 0.0035, 5.2e8)
    )

    // Bronze (Bz II) for high-strength messenger wires
    BronzeII := method(
        self withProps("Bz-II", 8900.0, 1.10e11, 1.7e-5, 2.50e-8, 0.0035, 6.0e8)
    )

    // Aluminum-Conductor Steel-Reinforced (ACSR) for heavy return/feeder cables
    ACSR := method(
        self withProps("ACSR-150", 3800.0, 0.80e11, 1.9e-5, 3.20e-8, 0.0040, 3.0e8)
    )

    // Stainless steel 316 for droppers
    Stainless316 := method(
        self withProps("Stainless-316", 7900.0, 1.93e11, 1.6e-5, 7.40e-7, 0.0009, 6.5e8)
    )
)
