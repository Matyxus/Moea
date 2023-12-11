# --------------------------- Structures --------------------------- 

# Problem definition
struct Definition{T, R}
    name::String # Name of the problem
    problem_type::Type{T} # Either Minimization or Maximization
    representation_type::Type{R} # Solution representation
    num_params::Int64 # Number of parameters (length of vector given to objective function)
    Definition(name::String, type::Type{T}, representation::Type{R}, params::Int64 = 1
    ) where {T <: ProblemType, R <: Representation} = new{T, R}(name, type, representation, params)
end

# Optimization definition
struct Optimization{N}
    objective::Function
    num_objectives::Int64  # Number of objective functions
    constraints::Function # G(x) -> g1(x), g2(x), ...., constrain function (or multiple)
    constraints_count::Int64 # Number of constraining functions
    bounds::Union{Nothing, NTuple{2, NTuple{N, Real}}}  # Bounds of variables (can be unlimited)
    bounds_count::Int64 # Number of bounds (must be equal to number of params, or zero!)
    Optimization(objective::Function, num_objectives::Int64, constraint::Function) = new{0}(objective, num_objectives, constraint, 1, nothing, 0)

    Optimization(objective::Function, num_objectives::Int64, constraint::Function, bounds::NTuple{2, NTuple{N, V}}
    ) where {N, V <: Real} = new{N}(objective, num_objectives, constraint, 1, bounds, length(bounds))

    Optimization(objective::Function, num_objectives::Int64, constraints::Vector{Function}
    ) = new{0}(objective, num_objectives, (x -> (|>).(Ref(x), constraints)), length(constraints), nothing, 0)

    Optimization(objective::Function, num_objectives::Int64, constraints::Vector{Function}, bounds::NTuple{2, NTuple{N, V}}
    ) where {N, V <: Real} = new{N}(objective, num_objectives, (x -> (|>).(Ref(x), constraints)), length(constraints), bounds, N)

    Optimization(objective::Vector{Function}, num_objectives::Int64, constraints::Vector{Function}, bounds::NTuple{2, NTuple{N, V}} 
    ) where {N, V <: Real} = new{N}(
        (x -> (|>).(Ref(x), objective)), num_objectives,
        (x -> (|>).(Ref(x), constraints)), length(constraints), 
        bounds, N
    )

    Optimization(objective::Vector{Function}, num_objectives::Int64, constraints::Vector{Function}) = new{0}(
        (x -> (|>).(Ref(x), objective)), num_objectives,
        (x -> (|>).(Ref(x), constraints)), length(constraints), 
        nothing, 0
    )
end

struct Problem
    definition::Definition
    optimization::Optimization
    Problem(definition::Definition, optimization::Optimization) = new(definition, optimization)
end

# --------------------------- Functions ---------------------------

function evaluate(solution::AbstractVector{T}, opt::Optimization)::Tuple{Union{AbstractVector, Real}, Real} where {T <: Real}
    # First we update the individual fitness
    value::Union{AbstractVector, Real} = opt.objective(solution)
    # Next update the constraint violation
    violation::Real = constrain_violation(opt.constraints(solution))
    # Finally update bounds violation, if there are some
    if opt.bounds_count != 0
        violation += bound_violation(solution, opt.bounds)
    end
    return value, violation
end

# --- Bounds --- 
bound_violation(solution::Any, bounds::Nothing)::Real = 0
bound_violation(solution::Real, bounds::NTuple{2, NTuple{1, Real}})::Real = (max(0, solution - bounds[2][1], bounds[1][1] - solution) > 0) ? Inf64 : 0
bound_violation(solution::Vector{<: Real}, bounds::NTuple{2, NTuple{N, Real}}) where {N} = (sum(max.(0, solution .- bounds[2], bounds[1] .- solution)) > 0) ? Inf64 : 0
# --- Constraints --- 
# Here we are assuming that constraints were transformed into "<= 0" forms
constrain_violation(constrain_value::Real)::Real = max(0, constrain_value)
constrain_violation(constraints_values::Vector{<: Real})::Real = sum(max.(0, constraints_values))
constrain_violation_squared(constrain_value::Real)::Real = max(0, constrain_value) ^ 2
constrain_violation_squared(constraints_values::Vector{<: Real})::Real = sum(max.(0, constraints_values) .^ 2)

# --------------------------------- Utils --------------------------------- 

function info(problem::Problem)::Nothing
    info(problem.definition)
    info(problem.optimization)
    return
end

function info(definition::Definition)::Nothing
    println("Problem: '$(definition.name)' of type: '$(definition.problem_type)'")
    println("Representation: '$(definition.representation_type)', parameter count: '$(definition.num_params)'")
    return
end

function info(optimization::Optimization)::Nothing
    println("Objectives: '$(optimization.num_objectives)' -> '$(optimization.objective)'")
    println("Constraints: '$(optimization.constraints_count)' -> '$(optimization.constraints)'")
    println("Bounds: '$(optimization.bounds_count)' -> '$(optimization.bounds)'")
    return
end

export Definition, Optimization, Problem, info, constrain_violation, constrain_violation_squared, bound_violation

