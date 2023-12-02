# --------------- Problem type --------------- 
abstract type ProblemType end
struct Minimization <: ProblemType end
struct Maximization <: ProblemType end

# --------------- Representation --------------- 

abstract type Representation end
is_type(::Any)::Nothing = nothing 
struct Permutation <: Representation end
struct Binary <: Representation end
struct Numbers <: Representation end
is_type(val::Vector{Int64})::Union{Type{Permutation}, Type{Numbers}} = (Set(val) == Set(1:length(val))) ? Permutation : Numbers 
is_type(::Vector{Bool})::Type{Binary} = Binary 
is_type(::BitVector)::Type{Binary} = Binary 
is_type(::Bool)::Type{Binary} = Binary 
is_type(::Vector{Float64})::Type{Numbers} = Numbers
is_type(::Float64)::Type{Numbers} = Numbers
is_type(::Int64)::Type{Numbers} = Numbers

const TYPE_MAP::Dict{Type{<: Representation}, Type{<: Real}} = Dict{Type{<: Representation}, Type{<: Real}}(
    Binary => Bool,
    Numbers => Real,
    Permutation => Int64
)

# --------------- Other --------------- 

const ϵ::Float64 = 0.0001



