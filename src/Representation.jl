mutable struct Individual{T, V}
    solution::AbstractVector{T} # Solution
    value::V # Function value 
    violation::Float64 # Sum of all constraint violations
    # NsgaII parameters
    rank::Int64 
    crowding_distance::Float64
    function Individual(solution::AbstractVector{T}, value::V = 0., violation::Float64 = 0.) where {T <: Real, V <: Union{AbstractVector, Real}}
        if isnothing(is_type(solution))
            println("Received invalid solution type!")
            return nothing
        else
            println("Received solution of type: $(is_type(solution))")
        end
        return new{T, V}(solution, value, violation, 0, 0.)
    end
end


# ---------------------- Domination of solutions ---------------------- 

function domination(problem_type::Union{Type{Maximization}, Type{Minimization}}, a::Individual, b::Individual)::Bool
    println("Checking if A: $(a) dominates: $(b) in $(problem_type)")
    if a.violation != b.violation
        println("Unequal violation!")
        return a.violation < b.violation
    end
    return dominates(problem_type, a.value, b.value)
end

dominates(::Type{Maximization}, value_a::Real, value_b::Real)::Bool = value_a > value_b
dominates(::Type{Minimization}, value_a::Real, value_b::Real)::Bool = value_a < value_b
dominates(::Type{Maximization}, value_a::Vector{<: Real}, value_b::Vector{<: Real})::Bool = all(value_a .>= value_b) && any(value_a .> value_b)
dominates(::Type{Minimization}, value_a::Vector{<: Real}, value_b::Vector{<: Real})::Bool = all(value_a .<= value_b) && any(value_a .< value_b)




