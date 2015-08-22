
using ValidatedNumerics
using FactCheck


A = [2 1; 1 1]

f(x) = A * x

function henon(xx)
    a = 1.4
    b = 0.3

    x, y = xx

    1 - a*x^2 + y, b*x
end

unit_interval = @interval(0, 1)
unit_square = IntervalBox(unit_interval, unit_interval)  # replace by constructor call in 0.4

facts("Image of unit square test") do
    @fact f(unit_square) --> IntervalBox(@interval(0, 3), @interval(0, 2))

    @fact henon(unit_square) --> IntervalBox(Interval(-0.40000000000000013, 2.0), Interval(0.0, 0.30000000000000004))
end

