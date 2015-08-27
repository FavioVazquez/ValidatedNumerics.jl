## Automatic differentiation
## Represents the jet of a function u at the point a by (u(a), u'(a))

immutable Jet{T} <: Number  # is this really a Number?  Then promotion rules work
    val::T   # value u(a)
    der::T   # derative u'(a)
end

Jet{T}(a::T, b::T) = Jet{T}(a, b)
#Jet(a, b) = Jet{T}(a,b)

# import Base:
#     convert, promote_rule, zero, one

convert(::Type{Jet}, c::Real) = Jet(c)
promote_rule{T<:Real, S<:Real}(::Type{Jet{T}}, ::Type{S}) = Jet

# Constants:
Jet(c::Real) = Jet(c, zero(c))

zero(x::Jet) = Jet(zero(x.val), zero(x.der))
one(x::Jet) = Jet(one(x.val), zero(x.der))


# Arithmetic between two Jets
+(x::Jet, y::Jet) = Jet(x.val + y.val, x.der + y.der)
-(x::Jet, y::Jet) = Jet(x.val - y.val, x.der - y.der)
*(x::Jet, y::Jet) = Jet(x.val*y.val, x.val*y.der + y.val*x.der)

function /(x::Jet, y::Jet)
    quotient = x.val / y.val
    der = (x.der - quotient*y.der) / y.val

    Jet(quotient, der)
end

-(x::Jet) = Jet(-x.val, -x.der)


# Elementary functions

sin(x::Jet) = Jet(sin(x.val), x.der*cos(x.val))
cos(x::Jet) = Jet(cos(x.val), -x.der*sin(x.val))
tan(x::Jet) = Jet(tan(x.val), x.der / cos(x.val)^2 )

asin(x::Jet) = Jet(asin(x.val), x.der / sqrt(1-x.val^2))
acos(x::Jet) = Jet(acos(x.val), -x.der / sqrt(1-x.val^2))
atan(x::Jet) = Jet(atan(x.val), x.der / (1+x.val^2))

exp(x::Jet) = Jet(exp(x.val), x.der * exp(x.val))
log(x::Jet) = Jet(log(x.val), x.der / x.val)

function ^(x::Jet, n::Integer)
    n == 0 && return one(x)
    n == 1 && return x
    Jet( (x.val)^n, n * (x.val)^(n-1) * x.der )
end

^(x::Jet, r::Rational) = (x^(r.num))^(1/r.den)
^(x::Jet, y::Real) = Jet( (x.val)^y, y * (x.val)^(y-1) * x.der )

differentiate(f::Function, a::Number) = f( Jet(a, one(a)) ).der

differentiate(f::Function) = x -> differentiate(f, x)
# caution: anonymous functions are currently slow (v0.3 of Julia)

const D = differentiate

function jacobian(f, a)

    f1(x) = f(x)[1]
    f2(x) = f(x)[2]

    J11 = D(x -> f1([x, b]), a)
	J12 = D(y -> f1([a, y]), b)
	J21 = D(x -> f2([x, b]), a)
	J22 = D(y -> f2([a, y]), b)

	[J11 J12; J21 J22]

end
