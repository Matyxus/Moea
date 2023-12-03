
function binary_tournament_selection(population::Vector{Individual}, size::Int64)::Vector{Int64}
    return [is_better(population[i], population[j]) ? i : j for (i, j) in zip(rand(1:size, size), rand(1:size, size))]
end



export binary_tournament_selection

