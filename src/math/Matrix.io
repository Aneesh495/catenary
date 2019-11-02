// Matrix.io
// Dense matrix operations, linear system solver, and tridiagonal Thomas algorithm.

doFile("src/math/Vector.io")

Matrix := Object clone do(
    rows := 0
    cols := 0
    data := nil

    zeros := method(numRows, numCols,
        m := self clone
        m rows = numRows
        m cols = numCols
        m data = List clone
        total := numRows * numCols
        for(i, 1, total, m data append(0.0))
        m
    )

    identity := method(n,
        m := self zeros(n, n)
        for(i, 0, n - 1,
            m atPut(i, i, 1.0)
        )
        m
    )

    at := method(r, c,
        idx := (r * (self cols)) + c
        self data at(idx)
    )

    atPut := method(r, c, val,
        idx := (r * (self cols)) + c
        self data atPut(idx, val asNumber)
        self
    )

    multiplyVector := method(vec,
        if(self cols != vec size,
            Exception raise("Matrix-vector dimension mismatch")
        )
        res := Vector zeros(self rows)
        for(r, 0, self rows - 1,
            acc := 0.0
            for(c, 0, self cols - 1,
                acc = acc + ((self at(r, c)) * (vec at(c)))
            )
            res atPut(r, acc)
        )
        res
    )

    multiplyMatrix := method(other,
        if(self cols != other rows,
            Exception raise("Matrix-matrix dimension mismatch")
        )
        res := Matrix zeros(self rows, other cols)
        for(r, 0, self rows - 1,
            for(c, 0, other cols - 1,
                acc := 0.0
                for(k, 0, self cols - 1,
                    acc = acc + ((self at(r, k)) * (other at(k, c)))
                )
                res atPut(r, c, acc)
            )
        )
        res
    )

    add := method(other,
        if(self rows != other rows or self cols != other cols,
            Exception raise("Matrix addition dimension mismatch")
        )
        res := Matrix zeros(self rows, self cols)
        total := (self rows) * (self cols)
        for(i, 0, total - 1,
            res data atPut(i, (self data at(i)) + (other data at(i)))
        )
        res
    )

    scale := method(scalar,
        res := Matrix zeros(self rows, self cols)
        total := (self rows) * (self cols)
        for(i, 0, total - 1,
            res data atPut(i, (self data at(i)) * scalar)
        )
        res
    )

    transpose := method(
        res := Matrix zeros(self cols, self rows)
        for(r, 0, self rows - 1,
            for(c, 0, self cols - 1,
                res atPut(c, r, self at(r, c))
            )
        )
        res
    )

    // Thomas algorithm for tridiagonal systems: A * x = d
    // a: subdiagonal (length n-1), b: main diagonal (length n), c: superdiagonal (length n-1), d: RHS (length n)
    solveTridiagonal := method(subDiag, mainDiag, superDiag, rhs,
        n := mainDiag size
        cPrime := Vector zeros(n - 1)
        dPrime := Vector zeros(n)

        // Forward elimination
        b0 := mainDiag at(0)
        if(b0 == 0.0, Exception raise("Singular tridiagonal system at index 0"))
        cPrime atPut(0, (superDiag at(0)) / b0)
        dPrime atPut(0, (rhs at(0)) / b0)

        for(i, 1, n - 2,
            ai := subDiag at(i - 1)
            denom := (mainDiag at(i)) - (ai * (cPrime at(i - 1)))
            if(denom == 0.0, Exception raise("Zero pivot in tridiagonal solver"))
            cPrime atPut(i, (superDiag at(i)) / denom)
            dPrime atPut(i, ((rhs at(i)) - (ai * (dPrime at(i - 1)))) / denom)
        )

        // Last element
        aLast := subDiag at(n - 2)
        denomLast := (mainDiag at(n - 1)) - (aLast * (cPrime at(n - 2)))
        if(denomLast == 0.0, Exception raise("Zero pivot in tridiagonal solver at last element"))
        dPrime atPut(n - 1, ((rhs at(n - 1)) - (aLast * (dPrime at(n - 2)))) / denomLast)

        // Back substitution
        x := Vector zeros(n)
        x atPut(n - 1, dPrime at(n - 1))
        for(i, n - 2, 0, -1,
            x atPut(i, (dPrime at(i)) - ((cPrime at(i)) * (x at(i + 1))))
        )
        x
    )

    // General Gaussian elimination with partial pivoting for dense matrix
    solve := method(rhsVec,
        n := self rows
        if(n != self cols or n != rhsVec size,
            Exception raise("Matrix dimensions invalid for linear solve")
        )

        // Create augmented matrix
        a := Matrix zeros(n, n)
        for(r, 0, n - 1,
            for(c, 0, n - 1,
                a atPut(r, c, self at(r, c))
            )
        )
        b := rhsVec copy

        // Forward elimination with partial pivoting
        for(k, 0, n - 2,
            // Find pivot
            maxVal := (a at(k, k)) abs
            maxRow := k
            for(i, k + 1, n - 1,
                val := (a at(i, k)) abs
                if(val > maxVal,
                    maxVal = val
                    maxRow = i
                )
            )
            if(maxVal < 1e-12, Exception raise("Singular matrix encountered in solve"))

            // Swap rows if needed
            if(maxRow != k,
                for(j, k, n - 1,
                    tmpA := a at(k, j)
                    a atPut(k, j, a at(maxRow, j))
                    a atPut(maxRow, j, tmpA)
                )
                tmpB := b at(k)
                b atPut(k, b at(maxRow))
                b atPut(maxRow, tmpB)
            )

            // Eliminate
            pivot := a at(k, k)
            for(i, k + 1, n - 1,
                factor := (a at(i, k)) / pivot
                for(j, k, n - 1,
                    a atPut(i, j, (a at(i, j)) - (factor * (a at(k, j))))
                )
                b atPut(i, (b at(i)) - (factor * (b at(k))))
            )
        )

        // Back substitution
        x := Vector zeros(n)
        for(i, n - 1, 0, -1,
            acc := b at(i)
            for(j, i + 1, n - 1,
                acc = acc - ((a at(i, j)) * (x at(j)))
            )
            diag := a at(i, i)
            if(diag abs < 1e-12, Exception raise("Zero diagonal in back substitution"))
            x atPut(i, acc / diag)
        )
        x
    )
)
