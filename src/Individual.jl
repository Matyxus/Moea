mutable struct Individual{T, V}
    solution::AbstractVector{T} # Solution
    value::V # Function value 
    violation::Real # Sum of all constraint violations
    # NsgaII parameters
    rank::Int64 
    crowding_distance::Float64
    function Individual(solution::AbstractVector{T}, value::V) where {T <: Real, V <: Union{AbstractVector, Real}}
        if isnothing(is_type(solution))
            println("Warning, Inidividual received invalid solution type: $(T)!")
        end
        return new{T, V}(solution, value, 0, 0, 0.)
    end
    function Individual(solution::AbstractVector{T}, value::V, violation::Real) where {T <: Real, V <: Union{AbstractVector, Real}}
        if isnothing(is_type(solution))
            println("Warning, Inidividual received invalid solution type: $(T)!")
        end
        return new{T, V}(solution, value, violation, 0, 0.)
    end
    Individual(solution::AbstractVector{T}, opt::Optimization) where {T <: Real} = Individual(solution, evaluate(solution, opt)...)
end

# ---------------------- Domination of solutions ---------------------- 

function domination(problem_type::Union{Type{Maximization}, Type{Minimization}}, a::Individual, b::Individual)::Bool
    # println("Checking if A: $(a) dominates: $(b) in $(problem_type)")
    if a.violation != b.violation
        # println("Unequal violation!")
        return a.violation < b.violation
    end
    return dominates(problem_type, a.value, b.value)
end

dominates(::Type{Maximization}, value_a::Real, value_b::Real)::Bool = value_a > value_b
dominates(::Type{Minimization}, value_a::Real, value_b::Real)::Bool = value_a < value_b
dominates(::Type{Maximization}, value_a::Vector{<: Real}, value_b::Vector{<: Real})::Bool = all(value_a .>= value_b) && any(value_a .> value_b)
dominates(::Type{Minimization}, value_a::Vector{<: Real}, value_b::Vector{<: Real})::Bool = all(value_a .<= value_b) && any(value_a .< value_b)

# ---------------------- Utils ---------------------- 

is_better(a::Individual, b::Individual)::Bool = (a.rank < b.rank) || (a.rank == b.rank && a.crowding_distance > b.crowding_distance)
is_feasible(indiv::Individual)::Bool = (indiv.violation ≈ 0)

export Individual, is_feasible
