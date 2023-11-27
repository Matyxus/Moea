abstract type ProblemType end
struct Minimization <: ProblemType end
struct Maximization <: ProblemType end

const ϵ::Float64 = 0.0001

# Problem definition
struct Definition{T, V}
    name::String # Name of the problem
    problem_type::Type{T} # Either Minimization or Maximization
    representation_type::Type{Representation} # Solution representation
    Definition(
        name::String, type::Type{T}, 
        representation::Type{R}
    ) where {T <: Problem, R <: Representation} = new{T, V}(name, type, representation)
end

struct Optimization{N}
    objective::Function
    constraints::Function
    constraints_count::Int64
    bounds::Union{Nothing, NTuple{2, NTuple{N, Real}}}
    bounds_count::Int64
    Optimization(objective::Function, constraint::Function) = new{Nothing}(objective, constraint, 1, nothing, 0)
    Optimization(
        objective::Function, constraints::Vector{Function}
    ) = new{Nothing}(objective, (x -> (|>).(Ref(x), constraints), length(constraints), nothing, 0))
    Optimization(
        objective::Function, constraint::Function, 
        bounds::NTuple{2, NTuple{N, V}}
    ) = new{Nothing}(objective, constraint, 1, nothing, 0)
    Optimization(
        objective::Function, constraints::Vector{Function}
    ) = new{Nothing}(objective, (x -> (|>).(Ref(x), constraints), length(constraints), nothing, 0))
end


struct Problem{T, N}
    # Problem specific vars
    name::String
    problem_type::Type{T}
    representation_type::Type{Representation}
    # Optimization vars
    objective::Function
    constraints::Union{Nothing, Vector{Function}, Function}
    constraints_count::Int64
    bounds::Union{Nothing, NTuple{2, NTuple{N, Real}}}
    bounds_count::Int64
    Problem(
        name::String, type::Type{T},
        representation::Type{R}, objective::Function, 
        constraints::Union{Vector{Function}, Function}
    ) where {T <: ProblemType, R <: Representation} = new{T, Nothing}(
        name, type, objective, representation, 
        (isa(constraints, Vector) ? (x -> (|>).(Ref(x), constraints), length(constraints)) : (constraints, 1))...,
        nothing, 0
    )
    Problem(
        name::String, type::Type{T}, 
        representation::Type{R}, objective::Function, 
        constraints::Union{Vector{Function}, Function},
        bounds::NTuple{2, NTuple{N, V}}
    ) where {T <: ProblemType, V <: Real, R <: Representation, N} = new{T, N}(
        name, type, representation, objective,
        (isa(constraints, Vector) ? (x -> (|>).(Ref(x), constraints), length(constraints)) : (constraints, 1))...,
        bounds, length(bounds)
    )
end

function info(problem::Problem)::Nothing
    println("Problem: $(problem.name) of type: $(problem_type)")
    println("Objective function: $(problem.objective)")
    println("Constrains: $(problem.constraints)")
    println("Bounds(lower, upper): $(problem.bounds)")
    return
end


function evaluate(indiv::Individual, problem::Problem)::Nothing
    @assert (length(indiv.solution) == problem.bounds_count)
    # First evaluate constrains
    g_violations::Union{Vector{Float64}} = abs.(problem.constraints(indiv.solution))
    println("Constrain violation: $(g_violations)")
    # We need to switch comparison from '<=' to '>=' to allow for multiplication
    result::Float64 = sum(g_violations .* (g_violations .>= 0))
    println("Sum constrain violation: $(result)")
    # After evaluate bounds
    if problem.bounds_count != 0
        println("Computing bounds violation")
        println("Solution: $(indiv.solution)")
    end

    # solution.violation = g_violation + bound_violation
    return
end


