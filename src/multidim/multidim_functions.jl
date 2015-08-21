
type MultidimFunction
    components::Vector{Function}
end

Base.getindex(f::MultidimFunction, i::Integer) = f.components[i]

Base.call(f::MultidimFunction, x) = (T=eltype(x); T[f_i(x) for f_i in f.components])


macro multidim(ex)
    
    syntax = :(throw(ArgumentError("Syntax: @multidim f(x)=[f1(x), f2(x)]")))

    ex.head == :(=) || return syntax
    
    func = ex.args[1]
    func.head == :call || return syntax
    
    f = func.args[1]
    x = func.args[2]
    
    #@show f
    #@show x
       
    
    try
        ex2 = ex.args[2].args[2]
    catch 
        throw(ArgumentError(syntax))
    end
    
    ex2 = ex.args[2].args[2]
    
    #@show ex2
    
    ex2.head == :(vect) || return syntax
    
    #rhs = :( [$x -> arg for arg in $(ex2.args)] )
    
    args = ex2.args
    #@show args
    
    
    rhs = :([])
    for arg in args
        push!(rhs.args, :($x -> $arg))
    end
    
    #@show rhs
    
    final = :( $(esc(f)) = MultidimFunction($rhs))
    #@show final
    
    final
    
end

@multidim f(x) = [sqrt(x[1]), 2x[2]]

x = [-1., 2.]
f(x)

f[1](x)

f[2](x)

# @multidim g(y) = [y[1], asin(y[1]-y[2])]
