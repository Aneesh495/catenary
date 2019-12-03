// StitchWire.io
// Stitch wire suspension at mast supports for high-speed stitch catenary systems.

StitchWire := Object clone do(
    mastX := 0.0             // Longitudinal location of mast support [m]
    stitchLength := 14.0     // Total length of stitch wire [m] (e.g. 7m either side of mast)
    tension := 3000.0        // Nominal tension [N]
    stiffness := 4.0e4       // Equivalent support stiffness [N / m]

    setupStitch := method(xPos, lenM, tensionN, stiffNm,
        s := self clone
        s mastX = xPos asNumber
        if(lenM != nil, s stitchLength = lenM asNumber)
        if(tensionN != nil, s tension = tensionN asNumber)
        if(stiffNm != nil, s stiffness = stiffNm asNumber)
        s
    )

    // Determines if coordinate x falls within the stitch wire span
    containsX := method(x,
        halfLen := self stitchLength * 0.5
        (x >= (self mastX - halfLen)) and (x <= (self mastX + halfLen))
    )

    // Restoring force on contact wire at position x
    restoringForce := method(x, yDisp,
        if(self containsX(x) not, return 0.0)
        halfLen := self stitchLength * 0.5
        distFromMast := (x - (self mastX)) abs
        // Shape factor tapering towards ends of stitch wire
        shapeFactor := 1.0 - (distFromMast / halfLen)
        -self stiffness * yDisp * shapeFactor
    )
)
