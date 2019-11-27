// MessengerWire.io
// Discretised messenger (catenary) wire with catenary sag geometry and dropper suspension.

doFile("src/mechanics/ConductorWire.io")
doFile("src/math/Vector.io")

MessengerWire := ConductorWire clone do(
    numNodes := 0
    dx := 0.0
    nominalSupportHeight := 6.50 // m above top of rail at mast supports
    sagAtMidspan := 0.80         // m nominal static sag

    displacement := nil          // Vector of vertical displacements
    velocity := nil
    acceleration := nil

    setupDiscretised := method(mat, areaM2, tensionN, lenM, nodeCount, supportHeight, midSag,
        w := self setupWire(mat, areaM2, tensionN, lenM)
        w numNodes = nodeCount
        w dx = lenM / (nodeCount - 1)
        if(supportHeight != nil, w nominalSupportHeight = supportHeight)
        if(midSag != nil, w sagAtMidspan = midSag)

        w displacement = Vector zeros(nodeCount)
        w velocity = Vector zeros(nodeCount)
        w acceleration = Vector zeros(nodeCount)
        w
    )

    // Theoretical parabolic catenary sag profile for a single span:
    // y_sag(x) = (mu * g * x * (L - x)) / (2 * T)
    staticSagAt := method(xInSpan, spanLength,
        mu := self linearMass
        g := 9.80665
        t := self currentTension
        if(t <= 0.0, return 0.0)
        (mu * g * xInSpan * (spanLength - xInSpan)) / (2.0 * t)
    )

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
)
