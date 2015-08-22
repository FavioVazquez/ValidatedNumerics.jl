using ValidatedNumerics

doc"""
The multidimensional Krawczyk operator acting on a (multi-dimensional) interval (box) $X$ is


$$K_f(X) := y - Y \cdot f(y) + [I - Y F'(X)] \cdot (X - y),$$

where $Y$ is a nonsingular real matrix approximating $F'(m(X))$ and
$y \in X$ is a real vector
"""



function Krawczyk2D(f::Function, X::IntervalBox)
    y = mid(X)

    Y = jacobian(f, y)
    Y = inv(Y)

    F′ = jacobian(f, X)

    IntervalBox(y - Y * f(y) + (I - Y * F′) * (X.intervals - y))
end

# Example from Moore pg. 118
f(xx) = ( (x,y) = xx; [x^2+y^2 - 1, x - y^2] )
X = IntervalBox(0.5..0.8, 0.6..0.9)

for i in 1:10
    #println("Applying Krawczyk 2D gives ", Krawczyk2D(f, X))
    X = Krawczyk2D(f, X)
end

println(X)
