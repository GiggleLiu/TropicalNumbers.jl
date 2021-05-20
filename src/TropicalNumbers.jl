module TropicalNumbers

export Tropical, TropicalF64, TropicalF32, TropicalF16, CountingTropicalF16, CountingTropicalF32, CountingTropicalF64, content
export CountingTropical
export TropicalTypes


include("tropical.jl")
include("counting_tropical.jl")

const TropicalTypes{T} = Union{CountingTropical{T}, Tropical{T}}

# alias
for NBIT in [16, 32, 64]
    @eval const $(Symbol(:Tropical, :F, NBIT)) = Tropical{$(Symbol(:Float, NBIT))}
    @eval const $(Symbol(:CountingTropical, :F, NBIT)) = CountingTropical{$(Symbol(:Float, NBIT)),$(Symbol(:Float, NBIT))}
end

# alias
for T in [:Tropical, :CountingTropical]
    # defining constants like `TropicalF64`.
    for OP in [:>, :<, :(==), :>=, :<=, :isless]
        @eval Base.$OP(a::$T, b::$T) = $OP(a.n, b.n)
    end
    @eval begin
        content(x::$T) = x.n
        content(x::Type{$T{X}}) where X = X
        Base.isapprox(x::AbstractArray{<:$T}, y::AbstractArray{<:$T}; kwargs...) = all(isapprox.(x, y; kwargs...))
        Base.show(io::IO, ::MIME"text/plain", t::$T) = Base.show(io, t)

        # this is for CUDA matmul
        Base.:(*)(a::$T, b::Bool) = b ? a : zero(a)
        Base.:(*)(b::Bool, a::$T) = b ? a : zero(a)
    end
end

end # module
