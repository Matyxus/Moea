import Distributions: Normal

function swap!(indiv::Individual)::Nothing
    @assert is_type(indiv.solution) == Permutation
    index1, index2 = rand(1:length(indiv.solution), 2)
    indiv.solution[index1], indiv.solution[index2] = indiv.solution[index2], indiv.solution[index1]
    return
end

function flip!(indiv::Individual, chance::Float64 = 0.1)::Nothing
    @assert is_type(indiv.solution) == Binary
    for i in 1:length(indiv.solution)
        if (rand() < chance)
           indiv.solution[i] = ~indiv.solution[i]
        end
    end
    return
end

function normal_mutation!(indiv::Individual, σ::Real = 1)::Nothing
    @assert is_type(indiv.solution) == Numbers
    indiv.solution += rand(Normal(0, σ), length(indiv.solution))
    return
end









