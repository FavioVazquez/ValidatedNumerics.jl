type IntervalBox{T} <: AbstractArray{T, 1}

    intervals::Vector{Interval{T}}

    #IntervalBox(a::Array{Interval, 1}) = new(a)

end

# implement array interface for IntervalBox
# (see http://julia.readthedocs.org/en/latest/manual/interfaces/):

Base.size(X::IntervalBox) = size(X.intervals)
Base.linearindexing(::Type{IntervalBox}) = Base.LinearFast()
Base.getindex(X::IntervalBox, i::Int) = X.intervals[i]


..(a, b) = @interval(a, b)
export ..

# typealias IntervalBox{T} Vector{Interval{T}}

IntervalBox(a...) = IntervalBox([a...;])

IntervalBox{T<:FloatingPoint}(a::Vector{T}) = IntervalBox(Interval{T}[@interval(x) for x in a])


-(X::IntervalBox, Y::IntervalBox) = IntervalBox(Interval{eltype(X)}[x-y for (x,y) in zip(X.intervals, Y.intervals)])


#IntervalBox(a::Vector) =

#IntervalBox(a...) = IntervalBox([a...;])

#IntervalBox(a::Vector) == IntervalBox([@interval(x) for x in a])

#IntervalBox(a::Vector) = IntervalBox([@interval(x) for x in a])  # convert real vector to interval vector -- should use convert?

#convert{T, S}(::Type{IntervalBox{T}}, a::Vector{S}) = IntervalBox([@interval(x) for x in a])

#Base.call(::Type{IntervalBox}, a...) = IntervalBox([a...])   # pack a list of intervals into an array

mid(X::IntervalBox) = [mid(x) for x in X.intervals]

⊆(X::IntervalBox, Y::IntervalBox) = all([x ⊆ y for (x,y) in zip(X.intervals, Y.intervals)])


#a = IntervalBox(1..2, 3..4)
#b = IntervalBox(0..2, 3..6)

#@assert a ⊆ b


function Base.show(io::IO, X::IntervalBox)
    for (i, x) in enumerate(X)
        print(io, x)
        if i != length(X)
            print(io, " × ")
        end
    end
end

