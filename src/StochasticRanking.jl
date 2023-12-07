mutable struct StochasticRanking
    problem::Problem
    population::Vector{Individual}
    # Methods
    initialization::Function
    selection::Function
    crossover::Function
    mutation!::Function
    # Parameters
    pop_size::Int64 # Is always odd number
    crossover_chance::Float64
    mutation_chance::Float64
    #
    function StochasticRanking(
            problem::Problem, init::Function, 
            selection::Function, crossover::Function, 
            mutation::Function; pop_size::Int64 = 100, 
            crossover_chance::Float64 = 0.25, mutation_chance::Float64 = 0.1
        )
        # Make sure pop size is odd
        @assert(pop_size > 0)
        pop_size += isodd(pop_size)
        return new(
            problem, initialize_population(problem, init, pop_size), 
            init, selection, crossover, mutation, pop_size,
            crossover_chance, mutation_chance
        )
    end
end



function step(sr::StochasticRanking)::Union{Vector{Individual}, Individual, Nothing}
    # println("Performing step of NsgaII algorithm")
    if isempty(sr.population)
        println("Error occured while initializing children!")
        return nothing
    end
    # ------ Selection, crossover, mutation, fitness ------ 
    # println("Performing selection, crossover, mutation and fitness")
    indexes::Vector{Int64} = sr.selection(sr.population, sr.pop_size)
    new_population::Vector{Individual} = []
    for _ in 1:2:sr.pop_size
        i, j = rand(indexes, 2)
        # Crossover
        a, b = (
            (rand() > sr.crossover_chance) ? 
            sr.crossover(sr.population[i].solution, sr.population[j].solution) : 
            (deepcopy(sr.population[i].solution), deepcopy(sr.population[j].solution))
        )
        # Mutation
        if (rand() > sr.mutation_chance); sr.mutation!(a) end
        if (rand() > sr.mutation_chance); sr.mutation!(b) end
        # Evaluation
        push!(new_population, generate_individual(StochasticRanking, a, sr.problem.optimization))
        push!(new_population, generate_individual(StochasticRanking, b, sr.problem.optimization))
    end
    # Generational replacement
    sr.population = new_population
    population_sort!(sr.population, sr.problem.definition.problem_type)
    # Return the best solutions (the ones which are feasible)
    return filter(x -> is_feasible(x), sr.population)
end


function population_sort!(population::Vector{Individual}, ::Type{Minimization}, P_f::Float64 = 0.45)::Nothing
    size::Int64 = length(population)
    # Bubble-sort
    swapped::Bool = true
    count::Int64 = size
    while (count != 0) && swapped
        swapped = false
        for j in 1:size-1
            # Compare based on function value
            if (is_feasible(population[j]) && is_feasible(population[j+1])) || (rand() < P_f)
                if population[j].value > population[j+1].value
                    swapped = true
                    population[j+1], population[j] = population[j], population[j+1] 
                end
            # Compared based on violation
            elseif population[j].violation > population[j+1].violation
                swapped = true
                population[j+1], population[j] = population[j], population[j+1]
            end
        end
        count -= 1
    end
    return
end

function population_sort!(population::Vector{Individual}, ::Type{Maximization}, P_f::Float64 = 0.45)::Nothing
    size::Int64 = length(population)
    # Bubble-sort
    swapped::Bool = true
    count::Int64 = size
    while (count != 0) && swapped
        swapped = false
        for j in 1:size-1
            # Compare based on function value
            if (is_feasible(population[j]) && is_feasible(population[j+1])) || (rand() < P_f)
                if population[j].value < population[j+1].value
                    swapped = true
                    population[j+1], population[j] = population[j], population[j+1] 
                end
            # Compared based on violation
            elseif population[j].violation > population[j+1].violation
                swapped = true
                population[j+1], population[j] = population[j], population[j+1]
            end
        end
        count -= 1
    end
    return
end



# ------------------------------- Utils ------------------------------- 

function generate_individual(::Type{StochasticRanking}, solution::AbstractVector{T}, opt::Optimization)::Individual where {T <: Real}
    return Individual(solution, opt.objective(solution), constrain_violation_squared(opt.constraints(solution)) + bound_violation(solution, opt.bounds))
end

function initialize_population(problem::Problem, init::Function, size::Int64)::Vector{Individual}
    println("Initializing population of type: $(problem.definition.representation_type), size: $(size)")
    println("Initialization function: $(init)")
    population::Vector{Individual} = [generate_individual(StochasticRanking, init(problem), problem.optimization) for _ in 1:size]
    if !all([is_type(indiv.solution) == problem.definition.representation_type for indiv in population])
        println("Error, expected child type: $(problem.definition.representation_type), but init returned other!")
        return []
    elseif !all([isa(indiv.value, Real) for indiv in population])
        println("Stochatic Ranking is only for single objective optimization!")
        return []
    end
    population_sort!(population, problem.definition.problem_type)
    return population
end


function info(sr::StochasticRanking)::Nothing
    info(sr.problem)
    println("Algorithm StochasticRanking, population: '$(sr.pop_size)'")
    println("Initialization: '$(sr.initialization)', selection: '$(sr.selection)'")
    println("Crossover: '$(sr.crossover)', chance: $(sr.crossover_chance)%")
    println("Mutation: '$(sr.mutation!)', chance: $(sr.mutation_chance)%")
    return
end


export StochasticRanking, step
