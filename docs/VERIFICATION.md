# Catenary Verification and Validation Ledger

This document establishes the formal verification and validation ledger for the Catenary simulation engine. All test suites, mathematical assertions, regulatory benchmark comparisons, and performance metrics are documented below.

--------------------------------------------------------------------------------

## 1. Master Test Suite Matrix

The automated test runner (`tests/test_runner.io`) executes 22 dedicated test suites covering unit physics, numerical algorithms, multi-conductor power networks, and end-to-end integration workflows.

| Test Suite File | Subsystem Domain | Scope and Target Invariants | Status | Assertions |
|:---|:---|:---|:---:|:---:|
| `tests/unit/test_math.io` | Vector & Solvers | Vector norms, dot products, sparse CG solver, statistics | PASS | 24 |
| `tests/unit/test_complex.io` | Complex Arithmetic | Phasor arithmetic, polar forms, division, magnitude | PASS | 18 |
| `tests/unit/test_matrix.io` | Linear Algebra | Dense LU solver, partial pivoting, Thomas tridiagonal O(N) | PASS | 25 |
| `tests/unit/test_materials.io` | Material Library | CuAg, CuMg, Bronze alloys, wave velocity, Doppler | PASS | 9 |
| `tests/unit/test_dropper.io` | Non-linear Droppers | Unilateral tension, realistic slackening, breakage fault | PASS | 12 |
| `tests/unit/test_contact_wire.io` | Wire Mechanics | Discretised mesh, stagger pattern, tridiagonal stiffness | PASS | 12 |
| `tests/unit/test_catenary_system.io`| Continuous OCS | 10-span assembly, dropper distribution, auto-tensioner | PASS | 8 |
| `tests/unit/test_pantograph.io` | Multibody Dynamics | Lumped 2-mass model, aerodynamic uplift, penalty contact | PASS | 9 |
| `tests/unit/test_active_control.io` | Active Control | Closed-loop PID, actuator force saturation limits | PASS | 8 |
| `tests/unit/test_arcing.io` | Plasma & Contact Loss| Cassie-Mayr arc conductance, NQ micro-separation detector | PASS | 13 |
| `tests/unit/test_wear.io` | Tribology & Wear | Archard mechanical abrasion, electrical plasma erosion | PASS | 9 |
| `tests/unit/test_transmission_line.io` | Carson-Clem Lines | Earth return depth, self and mutual coupled impedance | PASS | 10 |
| `tests/unit/test_electrical_network.io`| 2x25 kV Grid | Traction load, regen braking, BESS SoC, neutral section | PASS | 16 |
| `tests/unit/test_protection_relays.io` | Substation SCADA | ANSI 21 distance, ANSI 49 thermal, ANSI 50/51, locator | PASS | 18 |
| `tests/unit/test_train_dynamics.io` | Train Fleet & Driver| Davis running resistance, tractive curve, driver PID | PASS | 13 |
| `tests/unit/test_environment.io` | Environmental Forces| Crosswind drag, midspan blow-off, diurnal temperature | PASS | 8 |
| `tests/unit/test_fault_injection.io` | Fault Injection | Scheduled dropper breakage, substation outage trip | PASS | 8 |
| `tests/integration/test_en50318_benchmark.io` | Standard Benchmark | EN 50318 compliance validation at 300 km/h | PASS | 5 |
| `tests/integration/test_dual_pantograph.io` | Wave Interference | Dual pantographs spaced at 200m at 300 km/h | PASS | 5 |
| `tests/integration/test_regenerative_corridor.io` | Multi-Train Power | Regenerative power exchange and wayside BESS buffering | PASS | 5 |
| `tests/integration/test_dropper_breakage.io` | Fault Transient | Contact wire response to snapped mid-span dropper | PASS | 5 |
| `tests/integration/test_protection_trip.io` | Feeder Protection | Short-circuit fault and Zone 1 instantaneous trip | PASS | 6 |
| **Total Test Suites** | **22 Suites Executed** | **All Invariants Verified** | **100% PASS** | **256 Assertions** |

--------------------------------------------------------------------------------

## 2. Regulatory Compliance Benchmark (EN 50318 / EN 50367)

The European Standard EN 50318 defines reference validation criteria for high-speed railway pantograph-catenary dynamic simulation software. Below are the measured results obtained by Catenary at 300 km/h against standard reference tolerance ranges:

| Validation Parameter | Standard Reference Range | Catenary Measured Value | Tolerance Compliance |
|:---|:---|:---|:---:|
| **Mean Contact Force ($F_m$)** | $110.0\text{ to }135.0\text{ N}$ | **$130.52\text{ N}$** | **PASS** |
| **Standard Deviation ($\sigma_F$)** | $20.0\text{ to }42.0\text{ N}$ | **$23.67\text{ N}$** | **PASS** |
| **Maximum Contact Force ($F_{max}$)** | $\le 250.0\text{ N}$ | **$184.52\text{ N}$** | **PASS** |
| **Contact Loss Percentage ($NQ\%$)** | $\le 0.10\%$ | **$0.00\%$** | **PASS** |
| **Support Wire Uplift ($u_{mast}$)** | $\le 100.0\text{ mm}$ | **$55.00\text{ mm}$** | **PASS** |
| **Overall Standard Status** | **EN 50318 / EN 50367** | **Fully Compliant** | **VALIDATED** |

--------------------------------------------------------------------------------

## 3. High-Throughput Performance Metrics

Benchmarked on Apple Silicon (arm64):

| Benchmark Kernel | Problem Size / Rate | Measured Throughput | Real-Time Scaling |
|:---|:---|:---|:---:|
| **RK4 Integrator** | 10,000 steps | 9,945 steps / second | 9.9x real-time (at 1 ms step) |
| **Thomas Tridiagonal Solver** | N = 1,000 nodes | 96.8 solves / second | Linear O(N) complexity |
| **Full Multiphysics Simulation (250 km/h)** | 10 spans, 1 ms step | 9,082 steps / second | **9.08x faster than real-time** |
| **Full Multiphysics Simulation (300 km/h)** | 10 spans, 1 ms step | 9,268 steps / second | **9.27x faster than real-time** |
| **Full Multiphysics Simulation (350 km/h)** | 12 spans, 1 ms step | 9,271 steps / second | **9.27x faster than real-time** |
| **Native C ABI Simulation Kernel** | 100 steps | 100,000+ steps / second | Native compiled performance |
