// LumpedMassPantograph.io
// Multi-mass lumped parameter pantograph model per EN 50318 / EN 50367 benchmarks.

doFile("src/math/Vector.io")
doFile("src/math/Integrator.io")

LumpedMassPantograph := Object clone do(
    // 2-mass model default parameters (standard EN 50318 reference model)
    // Mass 1: Collector head assembly
    m1 := 6.60                // kg (collector head mass)
    k1 := 7000.0              // N / m (secondary suspension spring)
    c1 := 40.0                // N * s / m (secondary damper)

    // Mass 2: Articulated frame structure
    m2 := 18.00               // kg (frame equivalent mass)
    k2 := 0.0                 // N / m (pneumatic actuator spring stiffness)
    c2 := 70.0                // N * s / m (frame damper)

    // Preload and operational state
    staticPreload := 90.0     // N (static uplift force F0 applied to frame)
    currentX := 0.0           // Track longitudinal position [m]
    currentVelocity := 83.33  // Running velocity [m/s] (300 km/h)

    // Degrees of freedom: vertical displacements relative to nominal contact wire height (5.30m)
    y1 := 0.0                 // Head displacement [m]
    v1 := 0.0                 // Head velocity [m/s]
    a1 := 0.0                 // Head acceleration [m/s^2]

    y2 := 0.0                 // Frame displacement [m]
    v2 := 0.0                 // Frame velocity [m/s]
    a2 := 0.0                 // Frame acceleration [m/s^2]

    // Contact force history
    contactForce := 0.0       // N (positive when pushing up against contact wire)

    setupModel := method(headMassKg, frameMassKg, springK1, damperC1, damperC2, preloadN,
        p := self clone
        if(headMassKg != nil, p m1 = headMassKg asNumber)
        if(frameMassKg != nil, p m2 = frameMassKg asNumber)
        if(springK1 != nil, p k1 = springK1 asNumber)
        if(damperC1 != nil, p c1 = damperC1 asNumber)
        if(damperC2 != nil, p c2 = damperC2 asNumber)
        if(preloadN != nil, p staticPreload = preloadN asNumber)
        p
    )

    // Computes accelerations given external contact force F_contact (acting downwards on head)
    // and aerodynamic uplift force F_aero (acting upwards on frame/head)
    computeAccelerations := method(downwardContactForce, upwardAeroForce,
        // Equation of motion for Head (m1):
        // m1 * a1 = -k1*(y1 - y2) - c1*(v1 - v2) - F_contact
        internalSpringForce := (self k1 * (self y1 - self y2)) + (self c1 * (self v1 - self v2))
        f1Total := -internalSpringForce - downwardContactForce
        self a1 = f1Total / (self m1)

        // Equation of motion for Frame (m2):
        // m2 * a2 = k1*(y1 - y2) + c1*(v1 - v2) - k2*y2 - c2*v2 + F_static + F_aero
        f2Total := internalSpringForce - (self k2 * self y2) - (self c2 * self v2) + (self staticPreload) + upwardAeroForce
        self a2 = f2Total / (self m2)

        list(self a1, self a2)
    )

    // Advances state by time step dt using semi-implicit Euler / Verlet
    stepTime := method(dt, downwardContactForce, upwardAeroForce,
        self computeAccelerations(downwardContactForce, upwardAeroForce)

        // Velocity Verlet / Symplectic update
        self v1 = self v1 + (self a1 * dt)
        self y1 = self y1 + (self v1 * dt)

        self v2 = self v2 + (self a2 * dt)
        self y2 = self y2 + (self v2 * dt)

        // Advance longitudinal track position: x = x + v * dt
        self currentX = self currentX + (self currentVelocity * dt)
        self contactForce = downwardContactForce
        self
    )
)
