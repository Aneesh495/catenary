# Catenary Command-Line and API Reference Guide

## 1. Command-Line Interface (CLI)

The `catenary` executable driver provides porcelain and plumbing subcommands for execution, verification, regulatory benchmarking, and data export.

```bash
# Display help and command syntax
bin/catenary help

# Run interactive simulation at specified speed (km/h) and duration (seconds)
bin/catenary run 300 3.0

# Execute European Standard EN 50318 validation benchmark at 300 km/h
bin/catenary benchmark

# Execute master automated test suite runner across 22 verification suites
bin/catenary verify

# Execute a pre-configured scenario from the scenario library
bin/catenary scenario high_speed_350kmh
bin/catenary scenario dropper_failure_transient
bin/catenary scenario regenerative_braking_corridor
bin/catenary scenario short_circuit_relay_trip

# Run simulation and stream high-frequency time-series telemetry to CSV
bin/catenary export telemetry_output.csv
```

--------------------------------------------------------------------------------

## 2. Scenario Configuration Schema

Scenario files in `scenarios/` are formatted in JSON:

```json
{
  "scenario_id": "default_hsr_300kmh",
  "description": "Baseline 300 km/h single pantograph high-speed run on 2x25 kV catenary",
  "track": {
    "num_spans": 10,
    "span_length_m": 55.0,
    "catenary_type": "standard_hsr",
    "stagger_amplitude_m": 0.20
  },
  "catenary": {
    "contact_wire": {
      "material": "CuAg0.1",
      "cross_section_mm2": 120.0,
      "tension_kn": 25.0,
      "nominal_height_m": 5.30
    },
    "messenger_wire": {
      "material": "Bz-II",
      "cross_section_mm2": 65.0,
      "tension_kn": 18.0,
      "support_height_m": 6.50
    }
  },
  "pantograph": {
    "model": "lumped_2mass",
    "speed_kmh": 300.0,
    "static_preload_n": 90.0,
    "active_control": true
  },
  "simulation": {
    "duration_s": 3.0,
    "time_step_s": 0.001
  }
}
```

--------------------------------------------------------------------------------

## 3. Python Bindings API (`pycatenary`)

The `pycatenary` package provides native access via ctypes:

```python
from pycatenary.engine import CatenaryEngine
from pycatenary.analysis import EN50318Analyzer

# Initialize simulation context
engine = CatenaryEngine()
engine.initialize(num_nodes=1001, wire_length=550.0, tension=25000.0, speed_kmh=300.0)

# Execute 1.0 second simulation at 1 kHz (1000 steps)
forces = engine.simulate(duration_s=1.0, dt=0.001)

# Evaluate EN 50318 regulatory compliance
results = EN50318Analyzer.evaluate_compliance(forces, speed_kmh=300.0)
print(f"Mean Contact Force: {results['mean_contact_force_n']:.2f} N")
print(f"Standard Deviation: {results['std_deviation_n']:.2f} N")
print(f"Compliant: {results['overall_compliant']}")
```
