import Random: shuffle!

function uniform_init(problem::Problem)::Individual
    @assert (problem.definition.representation_type == Numbers) && (problem.optimization.bounds_count != 0)
    return Individual([rand(Uniform{Float64}(lb, ub)) for (lb, ub) in zip(opt.bounds[1], opt.bounds[2])])
end

function permutation_init(problem::Problem)::Individual
    @assert (problem.definition.representation_type == Permutation)
    return Individual(shuffle!(1:problem.definition.num_params...))
end

function binary_init(problem::Problem)::Individual
    @assert (problem.definition.representation_type == Binary)
    return Individual(bitrand(problem.definition.num_params))
end


