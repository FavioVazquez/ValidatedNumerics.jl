println("MULTIDIM")

type IntervalBox{T} <: AbstractArray{Interval{T}, 1}

    intervals::Vector{Interval{T}}

end

# implement array interface for IntervalBox
# (see http://julia.readthedocs.org/en/latest/manual/interfaces/):

Base.size(X::IntervalBox) = size(X.intervals)
Base.linearindexing(::Type{IntervalBox}) = Base.LinearFast()
Base.getindex(X::IntervalBox, i::Int) = X.intervals[i]

..(a, b) = @interval(a, b)
export ..


IntervalBox(a...) = IntervalBox([a...;])

IntervalBox{T<:FloatingPoint}(a::Vector{T}) = IntervalBox(Interval{T}[@interval(x) for x in a])


-(X::IntervalBox, Y::IntervalBox) = IntervalBox(Interval{eltype(X)}[x-y for (x,y) in zip(X.intervals, Y.intervals)])


mid(X::IntervalBox) = [mid(x) for x in X.intervals]

⊆(X::IntervalBox, Y::IntervalBox) = all([x ⊆ y for (x,y) in zip(X.intervals, Y.intervals)])

∩(X::IntervalBox, Y::IntervalBox) = IntervalBox([x ∩ y for (x,y) in zip(X.intervals, Y.intervals)])
isempty(X::IntervalBox) = any(map(isempty, X.intervals))

a = IntervalBox(1..2, 3..4)
b = IntervalBox(0..2, 3..6)

@assert a ⊆ b


function Base.show{T}(io::IO, X::IntervalBox{T})
    for (i, x) in enumerate(X)
        print(io, x)
        if i != length(X)
            print(io, " × ")
        end
    end
end

