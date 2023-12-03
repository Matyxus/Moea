import Distributions: Normal

function swap!(solution::Vector{Int64})::Nothing
    @assert is_type(solution) == Permutation
    index1, index2 = rand(1:length(solution), 2)
    solution[index1], solution[index2] = solution[index2], solution[index1]
    return
end

function flip!(solution::AbstractVector{Bool}, chance::Float64 = 0.1)::Nothing
    for i in eachindex(solution)
        if (rand() < chance)
            solution[i] = ~solution[i]
         end
    end
    return
end

function normal_mutation!(solution::Vector{Float64}, σ::Real = 1)::Nothing
    solution += rand(Normal(0, σ), length(solution))
    return
end


export swap!, flip!, normal_mutation!
