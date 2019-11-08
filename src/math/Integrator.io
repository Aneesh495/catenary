// Integrator.io
// Numerical time integration suite for structural dynamics and non-linear state spaces.

doFile("src/math/Vector.io")
doFile("src/math/Matrix.io")

Integrator := Object clone do(
    // Runge-Kutta 4th Order for first-order ODE system: dy/dt = f(t, y)
    // state: Vector, fBlock: block(t, y) returning Vector, dt: time step
    stepRK4 := method(t, state, dt, fBlock,
        k1 := fBlock call(t, state)
        k2 := fBlock call(t + (dt * 0.5), state add(k1 scale(dt * 0.5)))
        k3 := fBlock call(t + (dt * 0.5), state add(k2 scale(dt * 0.5)))
        k4 := fBlock call(t + dt, state add(k3 scale(dt)))

        // delta = (dt / 6) * (k1 + 2*k2 + 2*k3 + k4)
        sumK := k1 add(k2 scale(2.0)) add(k3 scale(2.0)) add(k4)
        state add(sumK scale(dt / 6.0))
    )

    // Symplectic Verlet integrator for second-order conservative systems: d2x/dt2 = a(t, x)
    stepVerlet := method(pos, vel, dt, accelBlock,
        a0 := accelBlock call(pos)
        halfVel := vel add(a0 scale(dt * 0.5))
        newPos := pos add(halfVel scale(dt))
        a1 := accelBlock call(newPos)
        newVel := halfVel add(a1 scale(dt * 0.5))
        list(newPos, newVel)
    )

    // Newmark-beta average acceleration method (gamma=0.5, beta=0.25)
    // for linear structural dynamics: M*u_ddot + C*u_dot + K*u = F(t)
    // Solves for u_{t+dt}, u_dot_{t+dt}, u_ddot_{t+dt}
    NewmarkBeta := Object clone do(
        gamma := 0.5
        beta := 0.25
        dt := 0.001

        mMatrix := nil
        cMatrix := nil
        kMatrix := nil
        effK := nil

        setup := method(mMat, cMat, kMat, timeStep,
            self mMatrix = mMat
            self cMatrix = cMat
            self kMatrix = kMat
            self dt = timeStep

            // K_eff = K + (1 / (beta * dt^2)) * M + (gamma / (beta * dt)) * C
            a0 := 1.0 / (self beta * (self dt squared))
            a1 := self gamma / (self beta * self dt)

            self effK = self kMatrix add(self mMatrix scale(a0)) add(self cMatrix scale(a1))
            self
        )

        step := method(u, uDot, uDDot, fNext,
            a0 := 1.0 / (self beta * (self dt squared))
            a1 := self gamma / (self beta * self dt)
            a2 := 1.0 / (self beta * self dt)
            a3 := (1.0 / (2.0 * self beta)) - 1.0
            a4 := (self gamma / self beta) - 1.0
            a5 := (self dt * 0.5) * ((self gamma / self beta) - 2.0)

            // Dynamic RHS: F_eff = F_next + M*(a0*u + a2*uDot + a3*uDDot) + C*(a1*u + a4*uDot + a5*uDDot)
            termM := u scale(a0) add(uDot scale(a2)) add(uDDot scale(a3))
            termC := u scale(a1) add(uDot scale(a4)) add(uDDot scale(a5))

            fEff := fNext add(self mMatrix multiplyVector(termM)) add(self cMatrix multiplyVector(termC))

            // Solve K_eff * u_next = fEff
            uNext := self effK solve(fEff)

            // Update accelerations and velocities
            uDDotNext := (uNext subtract(u)) scale(a0) subtract(uDot scale(a2)) subtract(uDDot scale(a3))
            uDotNext := uDot add(uDDot scale(self dt * (1.0 - self gamma))) add(uDDotNext scale(self dt * self gamma))

            list(uNext, uDotNext, uDDotNext)
        )
    )
)
