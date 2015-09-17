# This file is part of the ValidatedNumerics.jl package; MIT licensed

half_pi{T}(::Type{T}) = get_pi(T) / 2
two_pi{T}(::Type{T})  = get_pi(T) * 2

half_pi{T<:AbstractFloat}(x::T) = half_pi(T)


@doc doc"""Finds the quadrant(s) corresponding to a given floating-point
number. The quadrants are labelled as 0 for x ∈ [0, π/2], etc.
For numbers very near a boundary of the quadrant, a tuple of two quadrants
is returned. The minimum or maximum must then be chosen appropriately.

This is a rather indirect way to determine if π/2 and 3π/2 are contained
in the interval; cf. the formula for sine of an interval in
Tucker, *Validated Numerics*.""" ->

function find_quadrants(x::AbstractFloat)
    temp = x / half_pi(x)
    @compat (floor(Int, temp.lo), floor(Int, temp.hi))
end

function sin{T<:Real}(a::Interval{T})

    whole_range = Interval(-one(T), one(T))

    diam(a) >= two_pi(T).lo && return whole_range

    lo_quadrant = minimum(find_quadrants(a.lo))
    hi_quadrant = maximum(find_quadrants(a.hi))

    lo_quadrant = mod(lo_quadrant, 4)
    hi_quadrant = mod(hi_quadrant, 4)

    # Different cases depending on the two quadrants:
    if lo_quadrant == hi_quadrant
        a.hi - a.lo > get_pi(T).lo && return whole_range  # in same quadrant but separated by almost 2pi
        return @round(T, sin(a.lo), sin(a.hi))

    elseif lo_quadrant==3 && hi_quadrant==0
        return @round(T, sin(a.lo), sin(a.hi))

    elseif lo_quadrant==1 && hi_quadrant==2
        return @round(T, sin(a.hi), sin(a.lo))

    elseif ( lo_quadrant == 0 || lo_quadrant==3 ) && ( hi_quadrant==1 || hi_quadrant==2 )
        return @round(T, min(sin(a.lo), sin(a.hi)), one(T))

    elseif ( lo_quadrant == 1 || lo_quadrant==2 ) && ( hi_quadrant==3 || hi_quadrant==0 )
        return @round(T, -one(T), max(sin(a.lo), sin(a.hi)))

    elseif ( lo_quadrant == 0 && hi_quadrant==3 ) || ( lo_quadrant == 2 && hi_quadrant==1 )
        return whole_range
    else
        # This should be never reached!
        error(string("SOMETHING WENT WRONG in sin with argument $a; this should have never been reached.") )
    end
end


function cos{T<:Real}(a::Interval{T})

    whole_range = Interval(-one(T), one(T))

    diam(a) >= two_pi(T).lo && return whole_range

    lo_quadrant = minimum(find_quadrants(a.lo))
    hi_quadrant = maximum(find_quadrants(a.hi))

    lo_quadrant = mod(lo_quadrant, 4)
    hi_quadrant = mod(hi_quadrant, 4)

    # Different cases depending on the two quadrants:
    if lo_quadrant == hi_quadrant # Interval limits in the same quadrant
        a.hi - a.lo > get_pi(T).lo && return whole_range
        return @round(T, cos(a.hi), cos(a.lo))

    elseif lo_quadrant == 2 && hi_quadrant==3
        return @round(T, cos(a.lo), cos(a.hi))

    elseif lo_quadrant == 0 && hi_quadrant==1
        return @round(T, cos(a.hi), cos(a.lo))

    elseif ( lo_quadrant == 2 || lo_quadrant==3 ) && ( hi_quadrant==0 || hi_quadrant==1 )
        return @round(T, min(cos(a.lo), cos(a.hi)), one(T))

    elseif ( lo_quadrant == 0 || lo_quadrant==1 ) && ( hi_quadrant==2 || hi_quadrant==3 )
        return @round(T, -one(T), max(cos(a.lo), cos(a.hi)))

    elseif ( lo_quadrant == 3 && hi_quadrant==2 ) || ( lo_quadrant == 1 && hi_quadrant==0 )
        return whole_range
    else
        # This should be never reached!
        error(string("SOMETHING WENT WRONG in cos with argument $a; this should have never been reached.") )
    end
end


function tan{T<:Real}(a::Interval{T})
    whole_range = Interval{T}(-Inf, Inf)


    diam(a) >= get_pi(T).lo && return whole_range

    lo_quadrant = minimum(find_quadrants(a.lo))
    hi_quadrant = maximum(find_quadrants(a.hi))

    lo_quadrant_mod = mod(lo_quadrant, 2)
    hi_quadrant_mod = mod(hi_quadrant, 2)

    if lo_quadrant_mod == 0 && hi_quadrant_mod == 1
        return whole_range

    elseif lo_quadrant_mod == hi_quadrant_mod && hi_quadrant > lo_quadrant
        return whole_range
    end

    @round(T, tan(a.lo), tan(a.hi))

    # could return two disjoint intervals:
    # disjoint2 = Interval{T}( I.lo, Inf )
    # disjoint1 = Interval{T}( -Inf, I.hi)
    # info(string("The resulting interval is disjoint:\n", disjoint1, "\n", disjoint2,
    #            "\n The hull of the disjoint subintervals is considered:\n", rangeTan))
#     return whole_range
end


## Alternative definitions:

# Could define cos in terms of sin as follows, but it's slightly less accurate:
# cos{T<:Real}(a::Interval{T}) = sin(half_pi(T) - a)

# And tan in terms of sin and cos:
# tan{T<:Real}(a::Interval{T}) = sin(a) / cos(a)


function asin{T<:Real}(a::Interval{T})
    domain = Interval(-one(T), one(T))

    a = a ∩ domain

    isempty(a) && return a

    @round(T, asin(a.lo), asin(a.hi))
end

function acos{T<:Real}(a::Interval{T})
    domain = Interval{T}(-one(T), one(T))

    a = a ∩ domain

    isempty(a) && return a

    @round(T, acos(a.lo), acos(a.hi))
end

function atan{T<:Real}(a::Interval{T})

    @round(T, atan(a.lo), atan(a.hi))
end
