abstract type Representation end
is_type(::Any)::Union{Type{Representation}, Nothing} = nothing 

struct Permutation <: Representation end
struct Binary <: Representation end
struct Numbers <: Representation end
is_type(val::Vector{Int64})::Union{Type{Permutation}, Type{Numbers}} = all(val .== 1:length(val)) ? Permutation : Numbers 
is_type(::Vector{Bool})::Union{Type{Binary}, Nothing} = Binary 
is_type(::Vector{Float64})::Union{Type{Numbers}, Nothing} = Numbers


mutable struct Individual{T}
    solution::T # Solution (is_type must return its representation type, cannot be 'nothing')
    value::Real # Function value
    violation::Float64 # Sum of all constraint violations
    # NsgaII parameters
    rank::Int64 
    crowding_distance::Float64
    function Individual(solution::T, value::Float64 = 0., violation::Float64 = 0.) where {T <: AbstractArray}
        if isnothing(is_type(solution))
            println("Received invalid solution type!")
            return nothing
        else
            println("Received solution of type: $(is_type(solution))")
        end
        return new{T}(solution, value, violation, 0, 0.)
    end
end










