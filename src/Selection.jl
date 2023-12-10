
function binary_tournament_selection(population::Vector{Individual}, size::Int64)::Vector{Int64}
    len::Int64 = length(population)
    return [is_better(population[i], population[j]) ? i : j for (i, j) in zip(rand(1:len, size), rand(1:len, size))]
end

function tournament_selection(population::Vector{Individual}, size::Int64, tournament_size::Int64 = 5)::Vector{Int64}
    # We assume, that the population is already sorted
    len::Int64 = length(population)
    return [minimum(rand(1:len, tournament_size)) for _ in 1:size]
end

export binary_tournament_selection, tournament_selection

