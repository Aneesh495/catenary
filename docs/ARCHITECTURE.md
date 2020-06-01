# Catenary Architecture Specification

## 1. System Overview

Catenary is an object-oriented, prototype-based multiphysics simulation engine for high-speed railway electrification corridors. The engine couples:
1. Overhead Catenary System (OCS) continuous mechanical line dynamics
2. Pantograph multibody lumped-mass kinematics and contact mechanics
3. High-temperature plasma arc conductance and contact strip tribology
4. 2x25 kV Autotransformer (AT) traction electrification power networks
5. Substation SCADA protection automation (ANSI 21, 49, 50/51)
6. Autonomous train fleet dynamics and energy-efficient driver models

```
+---------------------------------------------------------------------------------+
|                                Catenary CLI & API                               |
|          run  |  benchmark  |  verify  |  scenario  |  export  |  pycatenary    |
+---------------------------------------------------------------------------------+
                                         |
+---------------------------------------------------------------------------------+
|                         Multiphysics Simulation Engine                          |
|             Multi-rate staggered coordination (1 ms / 10 ms / 1 s)              |
+---------------------------------------------------------------------------------+
                                         |
       +---------------------------------+---------------------------------+
       |                                                                   |
+-------------------------------+                         +-------------------------------+
|     Mechanical Subsystem      |                         |     Electrical Subsystem      |
|  - Contact Wire Discretisation|                         |  - 2x25 kV Substation (TPSS)  |
|  - Messenger Wire Catenary Sag|                         |  - Carson-Clem Impedance Lines|
|  - Unilateral Slack Droppers  |                         |  - 50/25 kV Autotransformers  |
|  - Steady Arms & Stagger      |                         |  - Nodal Admittance Solver    |
|  - Auto-Tensioning Wheel      |                         |  - Moving 4-Quadrant Loads    |
+-------------------------------+                         |  - Wayside BESS Storage Buffer|
       |                                                  |  - Neutral Section Dead Zones |
       v                                                  +-------------------------------+
+-------------------------------+                                          |
|      Pantograph Dynamics      |                                          v
|  - Multibody Lumped 2-Mass    |                         +-------------------------------+
|  - Aerodynamic Uplift Force   |                         |       SCADA Protection        |
|  - Penalty Contact Mechanics  |                         |  - ANSI 21 Distance Relay     |
|  - Active Closed-Loop Control |                         |  - ANSI 49 Thermal Overload   |
|  - Multi-Pantograph Spacing   |                         |  - ANSI 50/51 Overcurrent     |
+-------------------------------+                         |  - Traveling Wave Fault Loc   |
       |                                                  +-------------------------------+
       v                                                                   |
+-------------------------------+                                          |
|     Plasma & Tribology        |                                          |
|  - Cassie-Mayr Arc Equation   |                                          |
|  - EN 50318 Micro-Separation  |                                          |
|  - Archard Abrasive Wear      |                                          |
|  - Thermal Arc Plasma Erosion |                                          |
+-------------------------------+                                          |
       |                                                                   |
       +---------------------------------+---------------------------------+
                                         v
+---------------------------------------------------------------------------------+
|                          SCADA Telemetry & Validation                           |
|       - Live ANSI Force Gauge Dashboard      - EN 50318 Regulatory Benchmark    |
|       - High-Frequency CSV Time-Series       - C ABI Acceleration Library       |
+---------------------------------------------------------------------------------+
```

--------------------------------------------------------------------------------

## 2. Subsystem Decompositions

### 2.1 Mechanical Line Subsystem
- **ConductorWire**: Base prototype computing transverse wave velocity $c = \sqrt{T / \mu}$, Doppler amplification factor $1 / (1 - v/c)$, and thermal expansion length changes $\Delta L = L \alpha \Delta T$.
- **ContactWire**: 1D spatial discretisation carrying axial tension $T_c \approx 25\text{ kN}$, flexural rigidity $EI_c$, and lateral stagger pattern $z(x) = \pm 200\text{ mm}$ across spans.
- **MessengerWire**: Discretised catenary messenger cable carrying static parabolic sag profile $y_{sag}(x) = \frac{\mu g x (L - x)}{2 T_m}$.
- **Dropper**: Non-linear unilateral suspension link. When extended ($\Delta y > 0$), exhibits linear spring-damper restoring force $F = k_d \Delta y + c_d \Delta \dot{y}$. When compressed ($\Delta y \le 0$), exhibits complete structural slackening with zero compressive force ($F = 0$).
- **RegistrationArm**: Pivoting steady arm holding the contact wire at specified stagger offset while constraining maximum vertical uplift clearance.
- **Tensioner**: Pulley and counterweight auto-tensioning balance maintaining constant tension against diurnal temperature variations.

### 2.2 Pantograph Dynamics Subsystem
- **LumpedMassPantograph**: Multi-mass structural dynamic model per EN 50318:
  - Upper collector head: mass $m_1 = 6.6\text{ kg}$, secondary suspension $k_1 = 7000\text{ N/m}$, damper $c_1 = 40\text{ N*s/m}$.
  - Articulated frame: mass $m_2 = 18.0\text{ kg}$, frame damper $c_2 = 70\text{ N*s/m}$, static preload $F_0 = 90\text{ N}$.
- **AerodynamicUplift**: Velocity-dependent lift equation: $F_{aero}(v) = a_0 + a_1 v + a_2 v^2$.
- **ContactForce**: Unilateral penalty contact: $F_c = [k_c (y_{head} - y_{wire}) + c_c (\dot{y}_{head} - \dot{y}_{wire})]^+$.
- **ActiveControl**: Closed-loop PID controller modulating pneumatic/electromechanical force to suppress dropper passage harmonics.

### 2.3 Plasma Arc and Wear Subsystem
- **CassieMayrArc**: Dynamic electric arc conductance differential equation:
  $$\frac{1}{g} \frac{dg}{dt} = \frac{1}{\tau} \left[ \frac{u \cdot i}{P_0 + U_c^2 g} - g \right]$$
- **ContactLossDetector**: Tracks discrete micro-separations with duration $\ge 5\text{ ms}$ and computes percentage of contact loss $NQ\% = \frac{\sum t_{arc}}{t_{total}} \times 100\%$.
- **WearModel**: Combined Archard mechanical abrasive wear $V_{mech} = \frac{k_w F_n s}{H}$ and electrical plasma thermal erosion $V_{elec} = k_e I^{1.5} t_{arc}$.

### 2.4 Electrical 2x25 kV Traction Network
- **TransmissionLine**: Carson-Clem multi-conductor line model calculating self and mutual coupled impedance matrices with earth return path $D_e = 658 \sqrt{\rho / f}$.
- **Substation**: 2x25 kV Scott/Le Blanc stepdown transformer with split-phase secondary ($+27.5\text{ kV}$ positive catenary, $-27.5\text{ kV}$ negative feeder, neutral rail).
- **Autotransformer**: 50/25 kV center-tapped autotransformer balancing currents between catenary and feeder to suppress rail return currents.
- **NodalAdmittanceSolver**: Multi-conductor AC power flow solver calculating instantaneous nodal voltages and voltage drops.
- **EnergyStorage**: Wayside BESS supercapacitor energy buffer capturing regenerative braking energy during deceleration.
- **NeutralSection**: Phase break dead zone with automatic vacuum circuit breaker (VCB) switching balises.

### 2.5 Protection Relays and SCADA Automation
- **DistanceRelay21**: ANSI 21 distance protection monitoring apparent impedance $Z = V / I$ in the complex $R-X$ plane with Zone 1 instantaneous, Zone 2 delayed, and Zone 3 reverse/backup zones.
- **ThermalOverload49**: ANSI 49 conductor thermal replica relay based on IEEE 738 dynamic heat balance.
- **Overcurrent50_51**: ANSI 50 instantaneous and ANSI 51 IDMT inverse time overcurrent protection per IEC 60255.
- **FaultLocator**: Fault location estimation via line reactance and traveling wave transit time.
