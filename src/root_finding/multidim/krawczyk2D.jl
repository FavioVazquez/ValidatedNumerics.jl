using ValidatedNumerics

doc"""
The multidimensional Krawczyk operator acting on a (multi-dimensional) interval (box) $X$ is


$$K_f(X) := y - Y \cdot f(y) + [I - Y F'(X)] \cdot (X - y),$$

where $Y$ is a nonsingular real matrix approximating $F'(m(X))$ and
$y \in X$ is a real vector
"""

type MultiDimRoot{T}
    interval_box::IntervalBox{T}
end

Base.show(io::IO, X::MultiDimRoot) = print(io, X.interval_box)

function K(f::Function, X::IntervalBox)
    y = mid(X)
s
    Y = jacobian(f, y)
    Y = inv(Y)

    F′ = jacobian(f, X.intervals)

    IntervalBox( y - Y * f(y) + (I - Y * F′) * (X.intervals - y) )
end



function Krawczyk(f::Function, X::IntervalBox)

    KX = K(f, X)

    if KX ⊆ X
        #println("Contraction; unique root")

        X = KX

        while true
            KX = X ∩ K(f, X)

            if KX == X
                break
            end

            X = KX

        end

        return [MultiDimRoot(X)]


    elseif isempty(KX ∩ X)
        #println("No root in X=", X)
        return MultiDimRoot[]

    else
        # bisect largest
        (m, i) = findmax(map(diam, X.intervals))

        largest = X.intervals[i]
        m = mid(largest)

        Y1 = deepcopy(X)
        Y2 = deepcopy(X)

        Y1[i] = Interval(largest.lo, m)
        Y2[i] = Interval(m, largest.hi)

        #@show X, Y1, Y2

        return vcat(Krawczyk(f, Y1), Krawczyk(f, Y2))

    end
end


### Examples


# Example from Moore pg. 118
f(xx) = ( (x,y) = xx; [x^2+y^2 - 1, x - y^2] )
X = IntervalBox(0.5..0.8, 0.6..0.9)
X = IntervalBox(-5..5.1, -5..5.1)

roots = Krawczyk(f, X)
println(roots)


f(xx) = ( (x,y) = xx; [x^2+y^2 - 1, (x/2.)^2 + (y/0.5)^2-1] )

X = IntervalBox(-10..10.1, -10..10.1)
roots = Krawczyk(f, X)
println(roots)


# 3 variables:  http://www.wolframalpha.com/input/?i=solve+x%5E2%2By%5E2%2Bz%5E2-1+%3D+0+and+%28x%2F2%29%5E2%2B%28y%2F0.5%29%5E2+%2B%28z%2F0.75%29%5E2-1+%3D+0+and+y%2Bx%2Bz%3D0
# need 3x3 Jacobian:
f(xx) = ( (x,y,z) = xx; [x^2+y^2+z^2 - 1, (x/2.)^2 + (y/0.5)^2 + (z/0.7)^2-1, x+y+2z] )

X = IntervalBox(-10..10.1, -10..10.1, -10..10.1)

roots = Krawczyk(f, X)
println(roots)
