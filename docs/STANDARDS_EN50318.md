# European Standard EN 50318 Simulation Benchmark Specification

## 1. Regulatory Context

European Standard **EN 50318** (*Railway applications - Current collection systems - Validation of simulation of the dynamic interaction between pantograph and overhead contact line*) and **EN 50367** (*Railway applications - Current collection systems - Technical criteria for the interaction between pantograph and overhead line*) establish mandatory acceptance criteria for computer simulations of high-speed rail pantograph-catenary interaction.

To be certified for use in railway infrastructure design and vehicle homologation, a simulation code must reproduce standard benchmark models and prove that its statistical outputs fall within rigorously defined tolerance windows.

--------------------------------------------------------------------------------

## 2. Benchmark Model Characteristics

### 2.1 Catenary Physical Parameters
- System Type: AC 25 kV High-Speed Catenary
- Number of Spans: 10 spans (55 m nominal span length, 550 m total)
- Contact Wire:
  - Material: CuAg 0.1% alloy
  - Cross-section: 120 mm^2 ($\mu_c = 1.0692\text{ kg/m}$)
  - Axial Tension: $T_c = 25,000\text{ N}$ (25 kN)
  - Wave Velocity: $c = \sqrt{T_c / \mu_c} \approx 152.9\text{ m/s}$ (550.5 km/h)
  - Nominal Height: 5.30 m above top of rail
  - Lateral Stagger: $\pm 200\text{ mm}$ alternating at each mast
- Messenger Wire:
  - Material: Bronze II (Bz-II)
  - Cross-section: 65 mm^2 ($\mu_m = 0.5785\text{ kg/m}$)
  - Axial Tension: $T_m = 18,000\text{ N}$ (18 kN)
  - Support Height: 6.50 m at cantilevers
- Droppers:
  - Number per span: 9 droppers (spacing ~5.5 m)
  - Model: Unilateral spring with tension-only resistance ($k_d = 25,000\text{ N/m}$, $c_d = 50\text{ N*s/m}$)
  - Compressive behavior: Zero stiffness when compressed ($\Delta y \le 0$)

### 2.2 Pantograph Lumped-Mass Model
- Architecture: 2-mass multibody system
- Collector Head: $m_1 = 6.60\text{ kg}$, $k_1 = 7000\text{ N/m}$, $c_1 = 40\text{ N*s/m}$
- Frame Structure: $m_2 = 18.00\text{ kg}$, $k_2 = 0\text{ N/m}$, $c_2 = 70\text{ N*s/m}$
- Static Preload: $F_0 = 90.0\text{ N}$
- Aerodynamic Uplift: $F_{aero}(v) = 0.12 v + 0.0058 v^2\text{ N}$

--------------------------------------------------------------------------------

## 3. Mathematical Validation Criteria

The dynamic contact force time-series $F_c(t)$ must be filtered through a 1st order digital low-pass filter with a cutoff frequency $f_c = 20\text{ Hz}$. Over the steady-state evaluation section, the following metrics are assessed:

1. **Mean Contact Force ($F_m$)**:
   $$F_m = \frac{1}{N} \sum_{i=1}^N F_c(i)$$
   Standard Acceptance Band at 300 km/h: **$110.0\text{ N} \le F_m \le 135.0\text{ N}$**

2. **Standard Deviation ($\sigma_F$)**:
   $$\sigma_F = \sqrt{\frac{1}{N-1} \sum_{i=1}^N (F_c(i) - F_m)^2}$$
   Standard Acceptance Band at 300 km/h: **$20.0\text{ N} \le \sigma_F \le 42.0\text{ N}$**

3. **Maximum Contact Force ($F_{max}$)**:
   $$F_{max} = \max(F_c(t)) \le 250.0\text{ N}$$

4. **Percentage of Contact Loss ($NQ\%$)**:
   $$NQ = \frac{\sum t_{arc}}{t_{total}} \times 100\% \le 0.10\%$$
   A micro-separation is registered whenever the contact force drops below $5.0\text{ N}$ for a duration $\ge 5\text{ ms}$.

5. **Maximum Support Uplift ($u_{mast}$)**:
   $$u_{mast} \le 100.0\text{ mm}$$
