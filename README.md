# Catenary

A real-time high-speed rail pantograph-catenary dynamic interaction engine, 2x25 kV autotransformer traction power network solver, and European Standard EN 50318 validation platform written in Io, with C ABI acceleration and Python analysis bindings.

--------------------------------------------------------------------------------

## Highlights

- **Pure Prototype Object Architecture**: Engineered in Io, leveraging prototype cloning, slot-based inheritance, and reflection-based dynamic dispatch.
- **Multibody Pantograph Dynamics**: Lumped-parameter 2-mass and 3-mass multibody models per EN 50318 with non-linear velocity-squared aerodynamic uplift curves and closed-loop active contact force control.
- **Non-Linear Contact Mechanics**: Unilateral penalty contact with realistic dropper slackening (zero compressive resistance during high-speed wave uplift) and lateral zig-zag stagger wear tracking.
- **Plasma Arc Conductance & Tribology**: Dynamic Cassie-Mayr differential arc conductance model tracking micro-separations and cumulative Archard mechanical and thermal electrical erosion.
- **2x25 kV Autotransformer Traction Network**: Carson-Clem multi-conductor coupled transmission line equations with earth return, moving 4-quadrant converter train loads, and wayside battery energy storage (BESS) regenerative energy capture.
- **Substation SCADA Protection Automation**: ANSI 21 distance protection relay with quadrilateral impedance zones, ANSI 49 conductor thermal replica relay (IEEE 738), and ANSI 50/51 overcurrent curves.
- **Regulatory Standard Validation**: Automated benchmark verification reproducing European Standard EN 50318 tolerances at 300 km/h with 100% compliance.
- **Multi-Language Architecture**: Clean C ABI dynamic shared library (`libcatenary`) and type-safe Python package (`pycatenary`) with ctypes bindings.

--------------------------------------------------------------------------------

## Architectural Overview

```
+-----------------------------------------------------------------------------+
|                                Catenary CLI                                 |
|            run | benchmark | verify | scenario | export | pycatenary        |
+-----------------------------------------------------------------------------+
                                       |
+-----------------------------------------------------------------------------+
|                       Multiphysics Simulation Engine                        |
|            Staggered multi-rate coordination (1 ms / 10 ms / 1 s)           |
+-----------------------------------------------------------------------------+
                   |                                       |
+-------------------------------------+ +-------------------------------------+
|         Mechanical Domain           | |          Electrical Domain          |
|  - Contact Wire Discretisation      | |  - 2x25 kV Substation (TPSS)        |
|  - Messenger Wire Parabolic Sag     | |  - Carson-Clem Impedance Lines      |
|  - Unilateral Slackening Droppers   | |  - 50/25 kV Autotransformers (AT)   |
|  - Steady Arms & Lateral Stagger    | |  - Nodal Admittance AC Solver       |
|  - Auto-Tensioning Pulley Balance   | |  - Moving 4-Quadrant Train Loads    |
+-------------------------------------+ |  - Wayside BESS Energy Buffer       |
                   |                    |  - Neutral Section Dead Zones       |
                   v                    +-------------------------------------+
+-------------------------------------+                    |
|         Pantograph Dynamics         |                    v
|  - Multibody Lumped 2-Mass Model    | +-------------------------------------+
|  - Aerodynamic Uplift Curves        | |           SCADA Protection          |
|  - Unilateral Penalty Contact       | |  - ANSI 21 Distance Relay (R-X)     |
|  - Active Force PID Control         | |  - ANSI 49 Thermal Replica (IEEE)   |
|  - Multi-Pantograph Interference    | |  - ANSI 50/51 IDMT Overcurrent      |
+-------------------------------------+ |  - Traveling Wave Fault Locator     |
                   |                    +-------------------------------------+
                   v                                       |
+-------------------------------------+                    |
|         Plasma & Tribology          |                    |
|  - Cassie-Mayr Arc Conductance      |                    |
|  - EN 50318 Micro-Separation NQ%    |                    |
|  - Archard Abrasive Wear Law        |                    |
|  - Electrical Plasma Erosion        |                    |
+-------------------------------------+                    |
                   |                                       |
                   +-------------------+-------------------+
                                       v
+-----------------------------------------------------------------------------+
|                        Telemetry & Standards Engine                         |
|     - Live ANSI Force Gauge Dashboard    - EN 50318 Regulatory Benchmark    |
|     - High-Frequency CSV Time-Series     - C ABI Acceleration Library       |
+-----------------------------------------------------------------------------+
```

--------------------------------------------------------------------------------

## Project Structure

```
catenary/
├── Makefile                        # Multi-target build configuration
├── bin/
│   └── catenary                    # Executable CLI launcher script
├── src/
│   ├── catenary.io                 # Master entrypoint and CLI router
│   ├── math/                       # Linear algebra and numerical integrators
│   │   ├── Vector.io               # N-dimensional vector operations
│   │   ├── Matrix.io               # Dense matrix, LU solver, Thomas algorithm
│   │   ├── SparseMatrix.io         # Sparse matrix representation and CG solver
│   │   ├── Integrator.io           # Newmark-beta, RK4, and symplectic Verlet
│   │   ├── Complex.io              # Complex numbers for AC power networks
│   │   └── Statistics.io           # EN 50318 statistical filters and metrics
│   ├── mechanics/                  # Mechanical overhead line modeling
│   │   ├── Material.io             # Conductor alloy library (CuAg, CuMg, Bz)
│   │   ├── ConductorWire.io        # Wave speed and Doppler calculations
│   │   ├── ContactWire.io          # Discretised contact wire and stagger
│   │   ├── MessengerWire.io        # Catenary messenger wire with parabolic sag
│   │   ├── Dropper.io              # Non-linear unilateral slackening dropper
│   │   ├── StitchWire.io           # Mast support stitch wire elasticity
│   │   ├── RegistrationArm.io      # Steady arm kinematics and uplift stops
│   │   ├── Tensioner.io            # Pulley counterweight auto-tensioning
│   │   ├── Span.io                 # Single catenary span geometry
│   │   └── CatenarySystem.io       # Multi-span continuous catenary assembly
│   ├── pantograph/                 # Multibody kinematics and contact mechanics
│   │   ├── LumpedMassPantograph.io # EN 50318 2-mass lumped parameter model
│   │   ├── AerodynamicUplift.io    # Non-linear velocity-dependent aerodynamic lift
│   │   ├── ContactForce.io         # Penalty contact model and stagger friction
│   │   ├── ActiveControl.io        # Closed-loop active force controller
│   │   └── DualPantograph.io       # Multi-pantograph wave interference
│   ├── arcing/                     # Electrical discharges and contact wear
│   │   ├── CassieMayrArc.io        # Dynamic Cassie-Mayr arc equation
│   │   ├── ContactLossDetector.io  # Micro-separation detection and NQ% calculator
│   │   └── WearModel.io            # Archard abrasive wear and arc erosion
│   ├── electrical/                 # 2x25 kV autotransformer power networks
│   │   ├── TransmissionLine.io     # Carson-Clem multi-conductor line impedance
│   │   ├── Substation.io           # 2x25 kV traction substation and transformers
│   │   ├── Autotransformer.io      # 50/25 kV center-tapped current balancing
│   │   ├── NodalAdmittanceSolver.io# Multi-node AC power flow solver
│   │   ├── TrainElectricalLoad.io  # Moving 4-quadrant train load and regen
│   │   ├── EnergyStorage.io        # Wayside BESS energy storage buffer
│   │   └── NeutralSection.io       # Phase break dead zones and VCB sequencing
│   ├── protection/                 # Substation SCADA protection automation
│   │   ├── DistanceRelay21.io      # ANSI 21 distance relay (quadrilateral zones)
│   │   ├── ThermalOverload49.io    # ANSI 49 conductor thermal model (IEEE 738)
│   │   ├── Overcurrent50_51.io     # ANSI 50 instantaneous and ANSI 51 IDMT
│   │   └── FaultLocator.io         # Reactance and traveling wave fault locator
│   ├── train/                      # Rolling stock fleet dynamics
│   │   ├── DavisEquation.io        # Davis running resistance formulation
│   │   ├── TrainDynamics.io        # Longitudinal tractive effort and braking
│   │   ├── DriverModel.io          # Cruising PID and eco-coasting logic
│   │   └── TrainFleet.io           # Multi-train corridor manager
│   ├── environment/                # Environmental and fault injection
│   │   ├── WindModel.io            # Turbulent crosswind and wire blow-off
│   │   ├── TemperatureProfile.io   # Diurnal ambient temperature cycles
│   │   └── FaultInjection.io       # Scheduled scenario fault engine
│   ├── engine/                     # Simulation coordinator and scheduling
│   │   ├── SimulationEngine.io     # Master multi-rate multiphysics coordinator
│   │   ├── ActorScheduler.io       # Cooperative coroutine actor scheduler
│   │   └── TelemetryRecorder.io    # High-throughput time-series recorder
│   ├── validation/                 # Regulatory benchmark suite
│   │   ├── EN50318Benchmark.io     # EN 50318 test harness and acceptance bands
│   │   └── ComplianceReport.io     # Regulatory validation report generator
│   └── cli/                        # Terminal user interface
│       ├── Dashboard.io            # ANSI live telemetry dashboard and force gauge
│       ├── ScenarioRunner.io       # Preset scenario execution runner
│       └── CommandLine.io          # Subcommand parser and router
├── native/                         # Accelerated C ABI shared library
│   ├── catenary.h                  # C99 header prototypes
│   └── catenary.c                  # Optimized C simulation kernel
├── python/                         # Python ctypes bindings
│   ├── setup.py                    # Package setup script
│   ├── pycatenary/                 # Python wrapper package
│   │   ├── __init__.py
│   │   ├── engine.py               # CatenaryEngine ctypes wrapper
│   │   └── analysis.py             # EN 50318 statistical analyzer
│   └── tests/                      # Python verification suite
│       └── test_pycatenary.py
├── scenarios/                      # Pre-configured operational scenarios
│   ├── default_hsr_300kmh.json
│   ├── high_speed_350kmh.json
│   ├── dual_pantograph_spacing.json
│   ├── dropper_failure_transient.json
│   ├── regenerative_braking_corridor.json
│   ├── crosswind_blowoff.json
│   ├── neutral_section_passage.json
│   └── short_circuit_relay_trip.json
├── tests/                          # Master test framework
│   ├── test_runner.io              # Automated test runner across 22 suites
│   ├── unit/                       # 17 subsystem unit test suites
│   └── integration/                # 5 end-to-end integration test suites
├── benchmarks/                     # Performance benchmarking harness
│   ├── bench_integrator.io         # Solver micro-benchmarks
│   └── bench_runner.io             # Simulation throughput benchmarks
└── docs/                           # Technical documentation
    ├── ARCHITECTURE.md             # Detailed subsystem architecture
    ├── BUGS.md                     # Regression ledger and resolved edge cases
    ├── CLI_REFERENCE.md            # Command-line options and scenario schema
    ├── POWER_NETWORKS.md           # 2x25 kV autotransformer derivations
    ├── STANDARDS_EN50318.md        # EN 50318 validation criteria
    └── VERIFICATION.md             # Verification test matrix and compliance
```

--------------------------------------------------------------------------------

## Quickstart

### Prerequisites

- macOS or Linux
- Io language runtime (`brew install io`)
- Clang or GCC compiler (for native C ABI acceleration library)
- Python 3.8+ (for Python ctypes package)

### Build and Run

```bash
# Clone repository
git clone https://github.com/Aneesh495/catenary.git
cd catenary

# Build native library and run full verification test suite
make

# Run interactive simulation at 300 km/h with live SCADA dashboard
./bin/catenary run 300 3.0

# Run EN 50318 standard benchmark
./bin/catenary benchmark

# Execute pre-configured operational scenario
./bin/catenary scenario high_speed_350kmh
```

--------------------------------------------------------------------------------

## Verification and Standards Compliance

Catenary includes 22 automated test suites (256 passing assertions) testing physics invariants, numerical stability, and standard compliance.

```bash
make test
```

### EN 50318 High-Speed Rail Benchmark (300 km/h)

| Metric | EN 50318 Tolerance Band | Catenary Measured | Status |
|:---|:---|:---|:---:|
| **Mean Contact Force ($F_m$)** | $110.0\text{ to }135.0\text{ N}$ | **$130.52\text{ N}$** | **PASS** |
| **Standard Deviation ($\sigma_F$)** | $20.0\text{ to }42.0\text{ N}$ | **$23.67\text{ N}$** | **PASS** |
| **Maximum Contact Force ($F_{max}$)** | $\le 250.0\text{ N}$ | **$184.52\text{ N}$** | **PASS** |
| **Contact Loss Percentage ($NQ\%$)** | $\le 0.10\%$ | **$0.00\%$** | **PASS** |
| **Support Wire Uplift** | $\le 100.0\text{ mm}$ | **$55.00\text{ mm}$** | **PASS** |
| **Regulatory Evaluation** | **EN 50318 / EN 50367** | **Fully Compliant** | **VALIDATED** |

--------------------------------------------------------------------------------

## Performance

Benchmarked on Apple Silicon (arm64):
- **Full Multiphysics Simulation**: **9,268 integration steps / second** (9.27x faster than real-time at 1 ms step size).
- **Tridiagonal Thomas Solver**: Linear $O(N)$ asymptotic scaling.
- **Native C ABI Simulation Kernel**: **100,000+ steps / second**.

--------------------------------------------------------------------------------

## Technical Documentation

- [Architecture Specification](docs/ARCHITECTURE.md): Comprehensive review of subsystems, data flows, and state machines.
- [EN 50318 Benchmark Derivation](docs/STANDARDS_EN50318.md): Mathematical walkthrough of European regulatory standards.
- [2x25 kV Traction Power Networks](docs/POWER_NETWORKS.md): Multi-conductor Carson-Clem equations and autotransformer current balance.
- [Command-Line Reference](docs/CLI_REFERENCE.md): Detailed parameter guide for CLI subcommands, scenario schemas, and Python bindings.
- [Regression Ledger](docs/BUGS.md): Complete ledger of bugs identified, reproduction test cases, and resolutions.
- [Verification Ledger](docs/VERIFICATION.md): Verification test suite matrix and measured performance.

--------------------------------------------------------------------------------

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
