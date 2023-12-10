import Random: shuffle!

function uniform_init(problem::Problem)::Vector{Float64}
    @assert (problem.definition.representation_type == Numbers) && (problem.optimization.bounds_count != 0)
    return [rand(Uniform{Float64}(lb, ub)) for (lb, ub) in zip(problem.optimization.bounds[1], problem.optimization.bounds[2])]
end

function permutation_init(problem::Problem)::Vector{Int64}
    @assert (problem.definition.representation_type == Permutation)
    return shuffle!(1:problem.definition.num_params...)
end

function binary_init(problem::Problem)::BitVector
    @assert (problem.definition.representation_type == Binary)
    return bitrand(problem.definition.num_params)
end

export uniform_init, permutation_init, binary_init

