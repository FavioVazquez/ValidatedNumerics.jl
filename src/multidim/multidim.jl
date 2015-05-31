typealias MultiDimInterval Array{Interval, 1}


mid(x::MultiDimInterval) = map(mid, x)

