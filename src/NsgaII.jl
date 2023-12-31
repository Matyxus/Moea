# https://ieeexplore.ieee.org/document/996017
mutable struct NsgaII
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
    function NsgaII(
            problem::Problem, init::Function, 
            selection::Function, crossover::Function, 
            mutation::Function; pop_size::Int64 = 100, 
            crossover_chance::Float64 = 0.25, mutation_chance::Float64 = 0.1
        )
        # Make sure pop size is odd
        @assert(pop_size > 0)
        pop_size += isodd(pop_size)
        return new(
            problem, initialize_population(NsgaII, problem, init, pop_size), 
            init, selection, crossover, mutation, pop_size,
            crossover_chance, mutation_chance
        )
    end
end


function alg_step(nsga::NsgaII)::Union{Vector{Individual}, Individual, Nothing}
    # println("Performing step of NsgaII algorithm")
    if isempty(nsga.population)
        throw(ErrorException("Error, empty population set!"))
    end
    # ------ Selection, crossover, mutation, fitness ------ 
    # println("Performing selection, crossover, mutation and fitness")
    indexes::Vector{Int64} = nsga.selection(nsga.population, nsga.pop_size)
    for _ in 1:2:nsga.pop_size
        i, j = rand(indexes, 2)
        # Crossover
        a, b = (
            (rand() < nsga.crossover_chance) ? 
            nsga.crossover(nsga.population[i].solution, nsga.population[j].solution) : 
            (deepcopy(nsga.population[i].solution), deepcopy(nsga.population[j].solution))
        )
        # Mutation
        if (rand() < nsga.mutation_chance); nsga.mutation!(a) end
        if (rand() < nsga.mutation_chance); nsga.mutation!(b) end
        # Evaluation
        push!(nsga.population, Individual(a, nsga.problem.optimization))
        push!(nsga.population, Individual(b, nsga.problem.optimization))
    end
    # ------ Domination, crowding distance, replacement ------ 
    # println("Computing domination, crowding distance, replacement")
    domination_sort!(nsga.population, nsga.problem.definition.problem_type)
    # Set crowding distance only to solution, which will be picked in the next generation
    start::Int64 = 1
    for rank in nsga.population[start].rank:nsga.population[nsga.pop_size].rank
        last::Union{Int64, Nothing} = findnext(x -> x.rank == rank+1, nsga.population, start)
        last = (isnothing(last)) ? (nsga.pop_size * 2)+1 : last
        # Do not compute crowding distance for single or 2 elements
        if last <= start+2
            start = last
            continue
        end
        set_crowding_distance!(
            view(nsga.population, start:last-1), 
            nsga.problem.optimization.num_objectives, 
            nsga.problem.definition.problem_type
        )
        start = last
    end
    # Sort the last set, if it is unclear what will be taken into new population
    if nsga.population[nsga.pop_size].rank == nsga.population[nsga.pop_size+1].rank
        rank::Int64 = nsga.population[nsga.pop_size].rank
        first_index::Int64 = findfirst(x -> x.rank == rank, nsga.population)
        last_index::Int64 = findlast(x -> x.rank == rank, nsga.population)
        partialsort!(nsga.population, first_index:last_index, by = x -> x.crowding_distance, rev=true)
    end
    # Replacement strategy
    nsga.population = nsga.population[begin:nsga.pop_size]
    # Return all feasible solutions
    return filter(x -> is_feasible(x), nsga.population)
end


function domination_sort!(population::Vector{Individual}, problem_type::Union{Type{Maximization}, Type{Minimization}})::Nothing
    size::Int64 = length(population)
    # Domination fronts of each individual (other individual dominated by the current one), in index form
    fronts::Vector{Vector{Int64}} = [[] for _ in 1:size]
    # Total number of times solution is dominated by others
    dominance_count::Vector{Int64} = zeros(Int64, size)
    for i in 1:size
        # Check who solution dominates / is dominated by
        for j in i+1:size
            # "i" dominates "j"
            if domination(problem_type, population[i], population[j])
                push!(fronts[i], j)
                dominance_count[j] += 1
            # "j" dominates "i"
            elseif domination(problem_type, population[j], population[i])
                push!(fronts[j], i)
                dominance_count[i] += 1
            end
        end
        # Solution is not dominated by any other,
        # Also works as reset of rank for previous population (i.e. when it is direct copy)
        population[i].rank = (dominance_count[i] == 0)
        # Reset crowding distance
        population[i].crowding_distance = 0
    end
    # Current rank we are searching for
    rank::Int64 = 1
    changed_rank::Bool = true
    while changed_rank
        changed_rank = false
        for i in 1:size
            # Found solution with current rank, remove it from search
            if population[i].rank == rank
                changed_rank = true
                # For each solution dominated by the current one
                for j in fronts[i] 
                    dominance_count[j] -= 1
                    # Assign new rank, if solution is not dominated by any other
                    population[j].rank = (dominance_count[j] == 0) * (rank+1)
                end
            end
        end
        # Update rank
        rank += 1
    end
    # Sort by rank
    sort!(population, by = x -> x.rank)
    return
end

function set_crowding_distance!(population::AbstractVector{Individual}, objectives::Int64, problem_type::Union{Type{Maximization}, Type{Minimization}})::Nothing
    @assert length(unique([indiv.rank for indiv in population])) == 1
    # No need to compute crowding distance for only 2 or 1 individuals
    if length(population) <= 2
        population[begin].crowding_distance = population[end].crowding_distance = 0
        return
    end
    reversed::Bool = (problem_type == Maximization)
    len::Int64 = length(population)
    width::Real = 0
    if objectives == 1
        @assert all([isa(indiv.value, Real) for indiv in population])
        sort!(population, by = x -> x.value, rev=reversed)
        population[begin].crowding_distance = population[end].crowding_distance = Inf64
        # No need to compute crowding distance, if solutions have the same values
        if population[begin].value != population[end].value
            width = (population[end].value - population[begin].value)
            # Crowding distance is computed for the in-between solutions
            for i = 2:len-1
                population[i].crowding_distance += (population[i+1].value - population[i-1].value) / width
            end
        end
    else
        @assert all([length(indiv.value) == objectives for indiv in population])
        # Compute crowding distance for each objective
        for objective in 1:objectives 
            sort!(population, by = x -> x.value[objective], rev=reversed)
            population[begin].crowding_distance = population[end].crowding_distance = Inf64
            # No need to compute crowding distance, if solutions have the same values
            if population[begin].value[objective] != population[end].value[objective]
                width = (population[end].value[objective] - population[begin].value[objective])
                # Crowding distance is computed for the in-between solutions
                for i = 2:len-1
                    population[i].crowding_distance += (population[i+1].value[objective] - population[i-1].value[objective]) / width
                end
            end
        end
    end
    return
end


# ------------------------------- Utils ------------------------------- 

function initialize_population(::Type{NsgaII}, problem::Problem, init::Function, size::Int64)::Vector{Individual}
    println("Initializing population of type: $(problem.definition.representation_type), size: $(size)")
    println("Initialization function: $(init)")
    population::Vector{Individual} = [Individual(init(problem), problem.optimization) for _ in 1:size]
    if !all([is_type(indiv.solution) == problem.definition.representation_type for indiv in population])
        throw(ErrorException("Error, expected child type: $(problem.definition.representation_type), but init returned other!"))
    end
    return population
end


function info(nsga::NsgaII)::Nothing
    info(nsga.problem)
    println("Algorithm NSGA-II, population: '$(nsga.pop_size)'")
    println("Initialization: '$(nsga.initialization)', selection: '$(nsga.selection)'")
    println("Crossover: '$(nsga.crossover)', chance: $(nsga.crossover_chance * 100)%")
    println("Mutation: '$(nsga.mutation!)', chance: $(nsga.mutation_chance * 100)%")
    return
end


export NsgaII, alg_step, info
