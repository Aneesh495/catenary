// Complex.io
// Complex number arithmetic prototype for AC power systems and harmonic analysis.

Complex := Object clone do(
    re := 0.0
    im := 0.0

    with := method(realVal, imagVal,
        c := self clone
        c re = realVal asNumber
        c im = imagVal asNumber
        c
    )

    fromPolar := method(magnitude, angleRadians,
        c := self clone
        c re = magnitude * (angleRadians cos)
        c im = magnitude * (angleRadians sin)
        c
    )

    magnitude := method(
        ((self re squared) + (self im squared)) sqrt
    )

    magnitudeSquared := method(
        (self re squared) + (self im squared)
    )

    phase := method(
        (self im) atan2(self re)
    )

    conjugate := method(
        Complex with(self re, -(self im))
    )

    add := method(other,
        Complex with((self re) + (other re), (self im) + (other im))
    )

    subtract := method(other,
        Complex with((self re) - (other re), (self im) - (other im))
    )

    multiply := method(other,
        // (a + bi)(c + di) = (ac - bd) + (ad + bc)i
        r := ((self re) * (other re)) - ((self im) * (other im))
        i := ((self re) * (other im)) + ((self im) * (other re))
        Complex with(r, i)
    )

    scale := method(scalar,
        Complex with((self re) * scalar, (self im) * scalar)
    )

    divide := method(other,
        // (a + bi) / (c + di) = ((ac + bd) + (bc - ad)i) / (c^2 + d^2)
        denom := other magnitudeSquared
        if(denom == 0.0, Exception raise("Division by zero in Complex arithmetic"))
        r := (((self re) * (other re)) + ((self im) * (other im))) / denom
        i := (((self im) * (other re)) - ((self re) * (other im))) / denom
        Complex with(r, i)
    )

    reciprocal := method(
        Complex with(1.0, 0.0) divide(self)
    )

    equals := method(other, eps,
        if(eps == nil, eps = 1e-9)
        diffRe := ((self re) - (other re)) abs
        diffIm := ((self im) - (other im)) abs
        (diffRe < eps) and (diffIm < eps)
    )

    asString := method(
        sign := if(self im >= 0.0, "+", "-")
        (self re asString) .. " " .. sign .. " j" .. (self im abs asString)
    )
)
