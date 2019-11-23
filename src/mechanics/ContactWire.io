// ContactWire.io
// Discretised contact wire structural prototype under tension, bending, and dynamic uplift.

doFile("src/mechanics/ConductorWire.io")
doFile("src/math/Vector.io")
doFile("src/math/Matrix.io")

ContactWire := ConductorWire clone do(
    numNodes := 0
    dx := 0.0
    nominalHeight := 5.30    // m above top of rail
    staggerAmplitude := 0.20 // m (+/- 200 mm zig-zag stagger)

    // Dynamic state vectors across nodes
    displacement := nil      // Vector of vertical displacements y(x, t) relative to nominal height
    velocity := nil          // Vector of vertical velocities dy/dt
    acceleration := nil      // Vector of vertical accelerations d2y/dt2

    setupDiscretised := method(mat, areaM2, tensionN, lenM, nodeCount, nomHeight,
        w := self setupWire(mat, areaM2, tensionN, lenM)
        w numNodes = nodeCount
        w dx = lenM / (nodeCount - 1)
        if(nomHeight != nil, w nominalHeight = nomHeight)

        w displacement = Vector zeros(nodeCount)
        w velocity = Vector zeros(nodeCount)
        w acceleration = Vector zeros(nodeCount)
        w
    )

    // Stagger (lateral zig-zag position z(x)) to ensure uniform carbon strip wear
    // Triangular or sinusoidal waveform across span length
    staggerAt := method(x, spanLength,
        if(spanLength == nil, spanLength = 50.0)
        normX := (x % (2.0 * spanLength)) / spanLength
        if(normX <= 1.0,
            // From -stagger to +stagger
            -self staggerAmplitude + (2.0 * self staggerAmplitude * normX),
            // From +stagger to -stagger
            self staggerAmplitude - (2.0 * self staggerAmplitude * (normX - 1.0))
        )
    )

    // Node index nearest to longitudinal coordinate x
    nodeIndexAt := method(x,
        if(x <= 0.0, return 0)
        if(x >= self length, return (self numNodes - 1))
        (x / self dx) round
    )

    // Vertical position y(x) at longitudinal position x via linear interpolation
    interpolatedDisplacementAt := method(x,
        if(x <= 0.0, return self displacement at(0))
        if(x >= self length, return self displacement at(self numNodes - 1))

        idxFloat := x / self dx
        i := idxFloat floor
        frac := idxFloat - i
        if(i >= self numNodes - 1, return self displacement at(self numNodes - 1))

        y0 := self displacement at(i)
        y1 := self displacement at(i + 1)
        (y0 * (1.0 - frac)) + (y1 * frac)
    )

    // Assembles 1D wave-beam tridiagonal stiffness coefficients for internal wire tension
    // -T * (y_{i+1} - 2*y_i + y_{i-1}) / dx^2
    tridiagonalStiffnessVectors := method(
        n := self numNodes
        t := self currentTension
        coef := t / (self dx squared)

        subD := Vector zeros(n - 1)
        mainD := Vector zeros(n)
        supD := Vector zeros(n - 1)

        for(i, 0, n - 1,
            if(i == 0 or i == n - 1,
                // Fixed/pinned boundary at line anchors
                mainD atPut(i, 1.0),
                mainD atPut(i, 2.0 * coef)
                if(i > 0, subD atPut(i - 1, -coef))
                if(i < n - 1, supD atPut(i, -coef))
            )
        )
        list(subD, mainD, supD)
    )
)
