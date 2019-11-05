// SparseMatrix.io
// Coordinate (COO) and Compressed Sparse Row (CSR) matrix for large structural systems.

doFile("src/math/Vector.io")

SparseMatrix := Object clone do(
    rows := 0
    cols := 0
    entries := nil // Map of "r,c" -> value

    withDimensions := method(numRows, numCols,
        s := self clone
        s rows = numRows
        s cols = numCols
        s entries = Map clone
        s
    )

    atPut := method(r, c, val,
        key := (r asString) .. "," .. (c asString)
        if(val != 0.0,
            self entries atPut(key, val asNumber),
            self entries removeAt(key)
        )
        self
    )

    addAt := method(r, c, delta,
        key := (r asString) .. "," .. (c asString)
        current := self entries at(key)
        if(current == nil, current = 0.0)
        newVal := current + (delta asNumber)
        if(newVal != 0.0,
            self entries atPut(key, newVal),
            self entries removeAt(key)
        )
        self
    )

    at := method(r, c,
        key := (r asString) .. "," .. (c asString)
        val := self entries at(key)
        if(val == nil, 0.0, val)
    )

    multiplyVector := method(vec,
        if(self cols != vec size,
            Exception raise("SparseMatrix-vector dimension mismatch")
        )
        res := Vector zeros(self rows)
        self entries foreach(key, val,
            parts := key split(",")
            r := parts at(0) asNumber
            c := parts at(1) asNumber
            res atPut(r, (res at(r)) + (val * (vec at(c))))
        )
        res
    )

    // Conjugate Gradient solver for symmetric positive-definite sparse systems: A * x = b
    solveCG := method(rhsVec, maxIter, tol,
        if(maxIter == nil, maxIter = 1000)
        if(tol == nil, tol = 1e-8)
        n := self rows
        x := Vector zeros(n)
        r := rhsVec subtract(self multiplyVector(x))
        p := r copy
        rsOld := r dot(r)

        if(rsOld sqrt < tol, return x)

        for(iter, 1, maxIter,
            ap := self multiplyVector(p)
            alpha := rsOld / (p dot(ap))
            x = x add(p scale(alpha))
            r = r subtract(ap scale(alpha))
            rsNew := r dot(r)
            if(rsNew sqrt < tol,
                return x
            )
            p = r add(p scale(rsNew / rsOld))
            rsOld = rsNew
        )
        x
    )
)
