// Span.io
// Single catenary span structural geometry, dropper distributions, and pre-camber.

Span := Object clone do(
    index := 0
    startX := 0.0             // Start mast x coordinate [m]
    length := 55.0            // Span length [m] (typical 45-65 m)
    preSag := 0.0             // Intentional pre-sag / pre-camber at midspan [m] (e.g. 1/1000 of L)
    dropperSpacing := nil     // List of relative dropper positions within span [m]

    setupSpan := method(spanIdx, startPos, lenM, preCamberM, dropperList,
        s := self clone
        s index = spanIdx
        s startX = startPos asNumber
        if(lenM != nil, s length = lenM asNumber)
        if(preCamberM != nil, s preSag = preCamberM asNumber)
        if(dropperList != nil,
            s dropperSpacing = dropperList clone,
            // Default 9 droppers per 55m span (spacing ~5.5m)
            s dropperSpacing = list(4.5, 10.0, 15.5, 21.0, 27.5, 34.0, 39.5, 45.0, 50.5)
        )
        s
    )

    endX := method(
        (self startX) + (self length)
    )

    midspanX := method(
        (self startX) + ((self length) * 0.5)
    )

    containsX := method(x,
        (x >= self startX) and (x <= self endX)
    )

    // Theoretical pre-camber profile across span (parabolic):
    // y_camber(x) = -4 * preSag * (x' / L) * (1 - x' / L)
    preCamberAt := method(x,
        if(self containsX(x) not or self preSag == 0.0, return 0.0)
        xRel := (x - (self startX)) / (self length)
        -4.0 * (self preSag) * xRel * (1.0 - xRel)
    )
)
