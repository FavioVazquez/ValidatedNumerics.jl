using ValidatedNumerics

doc"""
The multidimensional Krawczyk operator acting on a (multi-dimensional) interval (box) $X$ is


$$K_f(X) := y - Y \cdot f(y) + [I - Y F'(X)] \cdot (X - y),$$

where $Y$ is a nonsingular real matrix approximating $F'(m(X))$ and
$y \in X$ is a real vector
"""



function K(f::Function, X::IntervalBox)
    y = mid(X)

    Y = jacobian(f, y)
    Y = inv(Y)

    F′ = jacobian(f, X)

    IntervalBox( y - Y * f(y) + (I - Y * F′) * (X.intervals - y) )
end



function Krawczyk(f::Function, X::IntervalBox)

    KX = K(f, X)

    if KX ⊆ X
        println("Contraction; unique root")

        X = KX

        while true
            KX = X ∩ K(f, X)

            if KX == X
                break
            end

            X = KX

        end

        return X


    elseif isempty(KX ∩ X)
        println("No root in X=", X)
        return

    else
        # bisect largest
        (m, i) = findmax(map(diam, X.intervals))

        largest = X.intervals[i]
        m = mid(largest)

        Y1 = deepcopy(X)
        Y2 = deepcopy(X)

        Y1[i] = Interval(largest.lo, m)
        Y2[i] = Interval(m, largest.hi)

        @show X, Y1, Y2

        return vcat(Krawczyk(f, Y1), Krawczyk(f, Y2))

    end
end

# Example from Moore pg. 118
f(xx) = ( (x,y) = xx; [x^2+y^2 - 1, x - y^2] )
X = IntervalBox(0.5..0.8, 0.6..0.9)

X = Krawczyk(f, X)
println("X = ", X)
