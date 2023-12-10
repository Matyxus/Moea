using Random
Random.seed!(42)
module Moea
# Structure definition + Utils
include("Constants.jl")
include("Problem.jl")
include("Individual.jl")
include("Log.jl")
include("Knapsack.jl")
# Methods
include("Visualization.jl")
include("Initialization.jl")
include("Selection.jl")
include("Mutation.jl")
include("Crossover.jl")
# Algorithms
include("NsgaII.jl")
include("StochasticRanking.jl")

function run_algorithm(max_iter::Int64, algorithm::Union{NsgaII, StochasticRanking}, log_name::String = "")::Union{Individual, Nothing}
    info(algorithm)
    best::Union{Individual, Nothing} = nothing
    updated::Bool = false
    println("Iterating: $(max_iter) iterations ...")
    log::Log = Log()
    for i in 1:max_iter
        solutions = alg_step(algorithm)
        # Compare solutions based on domination
        if !isnothing(solutions) && !isempty(solutions)
            if isnothing(best)
                updated = true
                best = solutions[begin]
            end
            for indiv in solutions
                if domination(algorithm.problem.definition.problem_type, indiv, best)
                    best = indiv
                    updated = true
                end
            end
            if updated
                add_result(log, i, best)
                updated = false
            end
        end
    end
    if !isempty(log_name)
        save_log(log_name, algorithm.problem, log)
    end
    return best
end

export run_algorithm
end


