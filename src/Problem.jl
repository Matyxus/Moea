# --------------------------- Structures --------------------------- 

# Problem definition
struct Definition{T, R}
    name::String # Name of the problem
    problem_type::Type{T} # Either Minimization or Maximization
    representation_type::Type{R} # Solution representation
    Definition(name::String, type::Type{T}, representation::Type{R}
    ) where {T <: ProblemType, R <: Representation} = new{T, R}(name, type, representation)
end

# Optimization definition
struct Optimization{N}
    objective::Function
    constraints::Function
    constraints_count::Int64
    bounds::Union{Nothing, NTuple{2, NTuple{N, Real}}}
    bounds_count::Int64 # == variable count
    Optimization(objective::Function, constraint::Function) = new{Nothing}(objective, constraint, 1, nothing, 0)

    Optimization(objective::Function, constraint::Function, bounds::NTuple{2, NTuple{N, V}}
    ) where {N, V <: Real} = new{N}(objective, constraint, 1, bounds, length(bounds))

    Optimization(objective::Function, constraints::Vector{Function}
    ) = new{0}(objective, (x -> (|>).(Ref(x), constraints)), length(constraints), nothing, 0)

    Optimization(objective::Function, constraints::Vector{Function}, bounds::NTuple{2, NTuple{N, V}}
    ) where {N, V <: Real} = new{N}(objective, (x -> (|>).(Ref(x), constraints)), length(constraints), bounds, length(bounds))
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
# Here wer are assuming that constraints were transformed into "<= 0" forms
constrain_violation(constrain_value::Real)::Float64 = max(0, constrain_value)
constrain_violation(constraints_values::Vector{<: Real})::Float64 = sum(max.(0, constraints_values))

# --------------------------------- Utils --------------------------------- 

function info(problem::Problem)::Nothing
    info(problem.definition)
    info(problem.optimization)
    return
end

function info(definition::Definition)::Nothing
    println("Problem: $(definition.name)")
    println("Type: $(definition.problem_type)")
    println("Representation: $(definition.representation_type)")
    return
end

function info(optimization::Optimization)::Nothing
    println("Objective: $(optimization.objective)")
    println("Constraints: $(optimization.constraints_count) -> $(optimization.constraints)")
    println("Bounds: $(optimization.bounds_count) -> $(optimization.bounds)")
    return
end



