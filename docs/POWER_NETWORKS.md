# 2x25 kV Autotransformer Traction Power Network Formulation

## 1. Electrical Topology of 2x25 kV Electrification

High-speed rail electrification universally adopts the 2x25 kV AC autotransformer (AT) system to deliver massive active power (up to 20-30 MW per trainset) while maintaining low voltage drops and minimizing electromagnetic interference with adjacent signaling and telecommunication infrastructure.

```
       +25 kV (Catenary Wire C)
  o====================*=======================*===================o
                       |                       |
                      ( )                     ( )
                      ( ) AT-1                ( ) AT-2
                       | Center Tap            | Center Tap
  ---------------------*-----------------------*-------------------- (Neutral Rail R, 0V)
                       |                       |
                      ( )                     ( )
                      ( )                     ( )
                       |                       |
  o====================*=======================*===================o
       -25 kV (Negative Feeder Wire F)
```

- Primary Transmission: Substation supplies 50 kV AC between Positive Catenary (+25 kV) and Negative Feeder (-25 kV).
- Center Tap: Solidly bonded to running rails and earthing conductors, maintaining rail potential near 0 V.
- Train Operation: Trains operate at 25 kV nominal voltage between catenary wire and running rails.

--------------------------------------------------------------------------------

## 2. Carson-Clem Multi-Conductor Impedance Matrix

For a system of $N$ overhead conductors with earth return, Carson-Clem equations compute the complex series impedance matrix $[Z] = [R] + j [X]$.

### 2.1 Earth Return Depth
The equivalent depth of fictitious earth return path $D_e$ is:
$$D_e = 658 \sqrt{\frac{\rho}{f}}\text{ [meters]}$$
where $\rho$ is the earth soil resistivity ($\Omega \cdot \text{m}$) and $f$ is the system frequency ($50\text{ or }60\text{ Hz}$). At $\rho = 100\ \Omega\cdot\text{m}$ and $f = 50\text{ Hz}$, $D_e \approx 931\text{ m}$.

### 2.2 Self-Impedance per Kilometer
$$Z_{ii} = r_i + \pi^2 f \times 10^{-4} + j 4 \pi f \times 10^{-4} \ln\left(\frac{D_e}{GMR_i}\right)\text{ }[\Omega / \text{km}]$$
where $r_i$ is conductor AC resistance ($\Omega/\text{km}$) and $GMR_i$ is the geometric mean radius.

### 2.3 Mutual Impedance per Kilometer
$$Z_{ij} = \pi^2 f \times 10^{-4} + j 4 \pi f \times 10^{-4} \ln\left(\frac{D_e}{D_{ij}}\right)\text{ }[\Omega / \text{km}]$$
where $D_{ij}$ is the physical spatial distance between conductors $i$ and $j$.

--------------------------------------------------------------------------------

## 3. Autotransformer Current Balancing

In an ideal AT section bounded by two autotransformers separated by distance $D$, a train at distance $x$ drawing load current $I_{train}$ induces winding currents that split as follows:
$$I_{catenary} = I_{train} \left(1 - \frac{x}{2 D}\right)$$
$$I_{feeder} = I_{train} \left(\frac{x}{2 D}\right)$$
The net rail current returning to the substation is:
$$I_{rail} = I_{catenary} - I_{feeder} = I_{train} \left(1 - \frac{x}{D}\right)$$
At mid-section ($x = D/2$), $I_{catenary} = I_{feeder}$, and the net current in the running rails collapses to exactly zero. Consequently, inductive interference on wayside signaling cables is reduced by 85% to 95% compared to classic 1x25 kV systems.
