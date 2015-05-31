typealias MultiDimInterval{T} Array{Interval{T}, 1}  # make into a true type?

#MultiDimInterval(a...) = [a...]   # pack a list of intervals into an array

mid(x::MultiDimInterval) = map(mid, x)

