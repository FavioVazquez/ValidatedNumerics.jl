# This file is part of the ValidatedNumerics.jl package; MIT licensed

using ValidatedNumerics
using FactCheck


facts("Constructing intervals") do
    set_interval_precision(53)
    @fact get_interval_precision() == (BigFloat,53) --> true

    set_interval_precision(Float64)
    @fact get_interval_precision() == (Float64,-1) --> true

    # Naive constructors, with no conversion involved
    @fact Interval(1) --> Interval{Float64}(1.0,1.0)
    @fact Interval(big(1)) --> Interval{Float64}(1.0,1.0)
    @fact Interval(2,1) --> Interval{Float64}(1.0,2.0)
    @fact Interval(big(2),big(1)) --> Interval{Float64}(1.0,2.0)
    @fact Interval(eu) --> Interval{Float64}(1.0*eu,1.0*eu)
    @fact Interval(1//10) --> Interval{Rational{Int}}(1//10,1//10)
    @fact Interval(BigInt(1)//10) --> Interval{Rational{BigInt}}(1//10,1//10)
    @fact Interval(BigInt(1),1//10) --> Interval{Rational{BigInt}}(1//10,1//1)
    @fact Interval(1,0.1) --> Interval{Float64}(0.1,1)
    @fact Interval(big(1),big(0.1)) --> Interval{BigFloat}(0.1,1)

    # Constructors that involve convert methods; does not work in v0.3
    if VERSION > v"0.4-"
        @fact Interval{Rational{Int}}(1) --> Interval(1//1)
        @fact Interval{Rational{Int}}(pi) --> Interval(rationalize(1.0*pi))
        @fact Interval{BigFloat}(1) --> Interval{BigFloat}(big(1.0),big(1.0))
        @fact Interval{BigFloat}(pi) -->
            Interval{BigFloat}(big(3.1415926535897931), big(3.1415926535897936))
    end


    # Conversions; may involve rounding
    @fact convert(Interval, 1) --> Interval(1.0)
    @fact convert(Interval, pi) --> Interval(3.1415926535897931, 3.1415926535897936)
    @fact convert(Interval, BigInt(1)) --> Interval(BigInt(1))
    # @fact convert(Interval, 1//10) --> @interval(1//10)
    @fact convert(Interval, 0.1) --> Interval(0.09999999999999999, 0.1)
    @fact convert(Interval, BigFloat(0.1)) --> Interval(big(0.1)) # without rounding


    # Constructors from the macros @interval, @floatinterval @biginterval
    set_interval_precision(53)
    a = @interval(0.1)
    @fact a --> @biginterval("0.1")
    @fact typeof(a) --> Interval{BigFloat}
    @fact nextfloat(a.lo) --> a.hi
    @fact float(a) --> @floatinterval(0.1)
    @fact @interval(pi) --> @biginterval(pi)

    set_interval_precision(Float64)
    a = @interval(0.1)
    # @fact a --> @floatinterval("0.1")
    @fact typeof(a) --> Interval{Float64}
    @fact nextfloat(a.lo) --> a.hi
    @fact float(@biginterval(0.1)) --> a
    @fact @interval(pi) --> @floatinterval(pi)

    # make_interval
    @fact ValidatedNumerics.make_interval(Rational{Int},a) --> Interval(1//10)
    if VERSION > v"0.4-"
        @fact ValidatedNumerics.make_interval(Rational{BigInt},pi) -->
            Interval{Rational{BigInt}}(pi)
    end


    # Some Old stuff moved here, slightly adapted
    a = @interval("[0.1, 0.2]")
    b = @interval(0.1, 0.2)

    @fact a ⊆ b --> true

    @fact_throws ArgumentError @interval("[0.1]")
    @fact_throws ArgumentError @interval("[0.1, 0.2")


    for precision in (64, Float64)
        set_interval_precision(precision)
        d = big(3)
        f = @interval(d, 2d)
        @fact @interval(3, 6) ⊆ f --> true
    end


    for rounding in (:wide, :narrow)

        set_interval_precision(Float64)

        a = @interval(0.1, 0.2)
        @fact a ⊆ Interval(0.09999999999999999, 0.20000000000000004) --> true

        b = @interval(0.1)
        @fact b ⊆ Interval(0.09999999999999999, 0.10000000000000002) --> true

        b = with_interval_precision(128) do
            @interval(0.1, 0.2)
        end
        @fact b ⊆ Interval(0.09999999999999999, 0.20000000000000004) --> true

        @fact float(b) ⊆ a --> true

        c = @interval("0.1", "0.2")
        @fact c ⊆ a --> true  # c is narrower than a
        @fact Interval(1//2) == Interval(0.5) --> true
        @fact Interval(1//10).lo == rationalize(0.1) --> true
    end

end
