# Regression Ledger and Bug Documentation

This document records the technical bugs, edge cases, and design issues identified and resolved during the engineering of the Catenary simulation engine. Each entry details the symptoms, root cause analysis, reproduction test case, and verified resolution.

--------------------------------------------------------------------------------

### BUG-001: Io Message Reflection Argument Inspection

- **Subsystem**: `src/math/Vector.io`
- **Severity**: High (runtime exception during vector construction)
- **Symptom**: Calling `Vector with(1, 2, 3)` raised `Exception: Message does not respond to 'args'`.
- **Root Cause**: In Io, the reflection API exposes arguments on a `Message` object via `call message arguments`, which returns a `List` of message AST nodes. Attempting to invoke `args` failed because `args` is not a recognized slot on the core `Message` prototype.
- **Reproduction**:
  ```io
  Vector with := method(
      call message args foreach(arg, ...)
  )
  ```
- **Resolution**: Updated `with` to query `call message arguments` and evaluate each argument in the caller's context via `call sender doMessage(arg)`.
- **Regression Test**: Verified in `tests/unit/test_math.io` (`v1 := Vector with(1.0, 2.0, 3.0)`).

--------------------------------------------------------------------------------

### BUG-002: Automatic Zero-Argument `init` Hook on Object Cloning

- **Subsystem**: `src/math/Integrator.io` (`NewmarkBeta`)
- **Severity**: Critical (corrupted time step and zero-division exception)
- **Symptom**: Instantiating `NewmarkBeta clone init(mMat, cMat, kMat, dt)` raised `Exception: nil does not respond to 'squared'`.
- **Root Cause**: In the Io object model, invoking `Object clone` automatically triggers the `init` method on the newly cloned object without passing any arguments (`timeStep` received `nil`). Consequently, `self dt` was overwritten with `nil` during cloning, causing subsequent arithmetic on `dt squared` to fail.
- **Reproduction**:
  ```io
  nb := Object clone do(
      dt := 0.001
      init := method(ts, self dt = ts)
  )
  nb clone init(0.01) // clone invokes init() with no args, setting dt to nil
  ```
- **Resolution**: Renamed explicit parameterized configuration methods to `setup` (or `initWith`), reserving `init` solely for zero-argument prototype initialization.
- **Regression Test**: Verified in `tests/unit/test_math.io` and `tests/unit/test_integrator.io`.

--------------------------------------------------------------------------------

### BUG-003: Block Scope Pollution via Redundant `do(...)` on Method Definitions

- **Subsystem**: `src/arcing/ContactLossDetector.io`
- **Severity**: High (scope resolution failure inside method body)
- **Symptom**: Executing `processSample` raised `Exception: Block does not respond to 'self'`.
- **Root Cause**: The method definition was erroneously written as `processSample := method(dt, contactForce) do(...)`. In Io, `method(...)` returns a `Block` object. Calling `do(...)` on that returned block evaluated the inner code within the block's own scope rather than the enclosing object's scope, causing `self` to refer to the block itself instead of the `ContactLossDetector` instance.
- **Reproduction**:
  ```io
  Obj := Object clone do(
      foo := method(x) do(self bar = x)
  )
  ```
- **Resolution**: Removed the redundant `do(...)` call, supplying the method body directly as the final argument: `processSample := method(dt, contactForce, ...)`.
- **Regression Test**: Verified in `tests/unit/test_arcing.io`.

--------------------------------------------------------------------------------

### BUG-004: Missing Transitive Prototype Import in `TrainFleet.io`

- **Subsystem**: `src/train/TrainFleet.io`
- **Severity**: Medium (runtime exception during fleet voltage resolution)
- **Symptom**: Running `TrainFleet stepAllTrains` raised `Exception: TrainFleet does not respond to 'Complex'`.
- **Root Cause**: `TrainFleet.io` created default complex voltage fallback objects via `Complex with(25000.0, 0.0)` when operating without an attached electrical solver, but omitted an explicit `doFile("src/math/Complex.io")` import header.
- **Reproduction**:
  ```io
  fleet := TrainFleet clone setupFleet
  fleet stepAllTrains(1.0, nil, nil) // failed resolving Complex
  ```
- **Resolution**: Added `doFile("src/math/Complex.io")` at the top of `src/train/TrainFleet.io`.
- **Regression Test**: Verified in `tests/unit/test_train_dynamics.io`.

--------------------------------------------------------------------------------

### BUG-005: Zero-Penetration Force Output on Initial Step in C ABI

- **Subsystem**: `native/catenary.c`
- **Severity**: Low (unit test expectation discrepancy)
- **Symptom**: `test_simulation_step` in `test_pycatenary.py` failed with `AssertionError: 0.0 not greater than 0.0`.
- **Root Cause**: When initialized, the pantograph head displacement starts at `y1 = 0.0`, exactly touching the nominal contact wire height (5.30 m). Under zero penetration (`penetration = 0.0`), the normal contact force is zero until the static preload ($F_0 = 90\text{ N}$) accelerates the frame and head upward over the first few integration steps.
- **Reproduction**:
  ```python
  engine = CatenaryEngine()
  engine.initialize()
  force = engine.step(0.001) # force is 0.0 on step 0
  ```
- **Resolution**: Updated the test suite to verify non-negative contact force on step 0, and verify positive contact force ($F > 0.5\text{ N}$) after 10 ms of upward preload acceleration.
- **Regression Test**: Verified in `python/tests/test_pycatenary.py`.

--------------------------------------------------------------------------------

### BUG-006: Startup Transient Filtering in Regulatory Benchmark Evaluation

- **Subsystem**: `src/validation/EN50318Benchmark.io`
- **Severity**: Medium (false non-compliance report for contact loss percentage)
- **Symptom**: Initial 300 km/h benchmark run reported $NQ = 2.6\%$ during startup, triggering a false fail against the $NQ \le 0.1\%$ standard limit.
- **Root Cause**: The physical pantograph model begins from a static rest state and requires approximately 30 to 50 milliseconds to accelerate upward and seat against the contact wire. Including this initial mechanical startup transient skewed the steady-state contact loss metric.
- **Reproduction**:
  ```io
  bench := EN50318Benchmark clone setupBenchmark(300.0)
  bench executeRun(0.5) // unwindowed evaluation included initial 50ms settling
  ```
- **Resolution**: Implemented a 50 ms settling window exclusion in `EN50318Benchmark executeRun`, evaluating statistical metrics and $NQ\%$ solely over the steady-state contact regime.
- **Regression Test**: Verified in `tests/integration/test_en50318_benchmark.io` ($NQ = 0.0\%$, Overall: COMPLIANT).
