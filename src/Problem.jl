abstract type ProblemType end
struct Minimization <: ProblemType end
struct Maximization <: ProblemType end

const ϵ::Float64 = 0.0001

struct Problem{T, N}
    name::String
    type::Type{T}
    objective::Function
    constraints::Union{Nothing, Vector{Function}, Function}
    bounds::Union{Nothing, NTuple{2, NTuple{N, Real}}}
    Problem(name::String, objective::Function, type::Type{T}) where {T <: ProblemType} = new{T, Nothing}(name, type, objective, nothing, nothing)
    Problem(
        name::String, objective::Function, 
        type::Type{T}, constraints::Union{Vector{Function}, Function}
    ) where {T <: ProblemType} = new{T, Nothing}(name, type, objective, constraints, nothing)
    Problem(
        name::String, objective::Function, 
        type::Type{T}, constraints::Union{Vector{Function}, Function},
        bounds::NTuple{2, NTuple{N, V}},
    ) where {T <: ProblemType, N, V <: Real} = new{T, N}(name, type, objective, constraints, bounds)
end

function info(problem::Problem)::Nothing
    println("Problem: $(problem.name) of type: $(problem.type)")
    println("Objective function: $(problem.objective)")
    println("Constrains: $(problem.constraints)")
    println("Bounds(lower, upper): $(problem.bounds)")
    return
end



