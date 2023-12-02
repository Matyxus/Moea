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
    ) where {N, V <: Real} = new{N}(objective, num_objectives, (x -> (|>).(Ref(x), constraints)), length(constraints), bounds, length(bounds))

    Optimization(objective::Vector{Function}, num_objectives::Int64, constraints::Vector{Function}, bounds::NTuple{2, NTuple{N, V}}; 
    ) where {N, V <: Real} = new{N}(
        (x -> (|>).(Ref(x), objective)), num_objectives,
        (x -> (|>).(Ref(x), constraints)), length(constraints), 
        bounds, length(bounds)
    )
end

struct Problem
    definition::Definition
    optimization::Optimization
    Problem(definition::Definition, optimization::Optimization) = new(definition, optimization)
end

# --------------------------- Functions --------------------------- 

function evaluate!(indiv::Individual, opt::Optimization)::Nothing
    # First we update the individual fitness
    indiv.value = opt.objective(indiv.solution)
    # Next update the constraint violation
    indiv.violation = constrain_violation(opt.constraints(indiv.solution))
    # Finally update bounds violation, if there are some
    if opt.bounds_count != 0
        indiv.violation += bound_violation(indiv.solution, opt.bounds)
    end
    return
end
# --- Bounds --- 
bound_violation(solution::Real, bounds::NTuple{2, NTuple{1, Real}})::Float64 = max(0, solution - bounds[2][1], bounds[1][1] - solution)
bound_violation(solution::Vector{<: Real}, bounds::NTuple{2, NTuple{N, Real}}) where {N} = sum(max.(0, solution .- bounds[2], bounds[1] .- solution))
# --- Constraints --- 
# Here we are assuming that constraints were transformed into "<= 0" forms
constrain_violation(constrain_value::Real)::Float64 = max(0, constrain_value)
constrain_violation(constraints_values::Vector{<: Real})::Float64 = sum(max.(0, constraints_values))

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

function check_params(definition::Definition, optimization::Optimization)::Bool
    
end


