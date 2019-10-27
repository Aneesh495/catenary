// Vector.io
// High-performance n-dimensional numerical vector prototype.

Vector := Object clone do(
    data := nil

    with := method(
        v := self clone
        v data = List clone
        call message arguments foreach(arg,
            v data append(call sender doMessage(arg))
        )
        v
    )

    fromList := method(aList,
        v := self clone
        v data = aList clone
        v
    )

    zeros := method(n,
        v := self clone
        v data = List clone
        for(i, 1, n, v data append(0.0))
        v
    )

    size := method(
        if(self data == nil, 0, self data size)
    )

    at := method(idx,
        self data at(idx)
    )

    atPut := method(idx, val,
        self data atPut(idx, val)
        self
    )

    add := method(other,
        n := self size
        res := Vector zeros(n)
        for(i, 0, n - 1,
            res atPut(i, (self at(i)) + (other at(i)))
        )
        res
    )

    subtract := method(other,
        n := self size
        res := Vector zeros(n)
        for(i, 0, n - 1,
            res atPut(i, (self at(i)) - (other at(i)))
        )
        res
    )

    scale := method(scalar,
        n := self size
        res := Vector zeros(n)
        for(i, 0, n - 1,
            res atPut(i, (self at(i)) * scalar)
        )
        res
    )

    dot := method(other,
        n := self size
        acc := 0.0
        for(i, 0, n - 1,
            acc = acc + ((self at(i)) * (other at(i)))
        )
        acc
    )

    norm := method(
        (self dot(self)) sqrt
    )

    normSquared := method(
        self dot(self)
    )

    copy := method(
        v := self clone
        v data = self data clone
        v
    )

    asString := method(
        buf := Sequence clone appendSeq("[")
        n := self size
        for(i, 0, n - 1,
            buf appendSeq(self at(i) asString)
            if(i < n - 1, buf appendSeq(", "))
        )
        buf appendSeq("]")
        buf
    )
)
