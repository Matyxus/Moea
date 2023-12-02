import Distributions: Uniform
# ------------------- Permutation ------------------- 

"""
    function pmx(a::Individual, b::Individual)::Tuple{Individual, Individual}

    Performs crossover operation, by selecting two indexes then copies
    a[from:to] to the new solution, the rest is filled from "b".
    The absolute position of permutation numbers in "b" is kept as close as possible in 
    the new solution. This is done by creating mapping between a[from:to] and b[from:to].
    Similary starting with "b", the second solution in created.
    Operator only works for permutation representation.

# Arguments
- `a::Individual`: First parent - solution
- `b::Individual`: Second parent - solution

`Returns` Tuple containing newly generated solutions (of Permutation representation)
"""
function pmx(a::Individual, b::Individual)::Tuple{Individual, Individual}
    @assert is_type(a.solution) == is_type(b.solution) == Permutation
    len::Int64 = length(a.solution)
    from, to = rand(1:len, 2)
    from, to = from > to ? (to, from) : (from, to)

    function generate_child(A::Individual, B::Individual)::Individual
        child::Vector{Int64} = zeros(Int64, len)
        # Copy middle part from parent B
        child[from:to] = B.solution[from:to]
        mapping::Dict{Int64, Int64} = Dict{Int64, Int64}(zip(child[from:to], A.solution[from:to]))
        # Fill the missing permutation numbers from parents
        for i in vcat(1:from-1, to+1:len)
            item::Int64 = A.solution[i]
            # There can be multiple mappings, iterate till its not present
            while (haskey(mapping, item))
                item = mapping[item]
            end
            child[i] = item
        end
        return Individual(child)
    end
    return generate_child(a, b), generate_child(b, a)
end


# ------------------- Binary and Numbers ------------------- 

"""
    function one_point_crossover(a::Individual, b::Individual)::Tuple{Individual, Individual}

    Performs crossover operation, by using inverse sequence of city id's
    and randomly selected index, a[1:index] is combined with 
    b[index+1:end] to create new route (another using "b" first).
    Operator works for Binary and Numbers representations.

# Arguments
- `a::Individual`: First parent - solution
- `b::Individual`: Second parent - solution

`Returns` Tuple containing newly generated solutions
"""
function one_point_crossover(a::Individual, b::Individual)::Tuple{Individual, Individual}
    @assert (is_type(a.solution) == is_type(b.solution) in [Numbers, Binary])
    crossover_point::Int64 = rand(1:(length(a.solution)-1))
    return (
        Individual(append!(a.solution[1:crossover_point],  b.solution[crossover_point+1:end])),
        Individual(append!(b.solution[1:crossover_point],  a.solution[crossover_point+1:end]))
    )
end

function uniform_crossover(a::Individual, b::Individual)::Tuple{Individual, Individual}
    @assert (is_type(a.solution) == is_type(b.solution) in [Numbers, Binary])
    len::Int64 = length(a.solution)
    mask::BitVector = bitrand(len)
    return (
        Individual([mask[i] ? a.solution[i] : b.solution[i] for i in 1:len]),
        Individual([mask[i] ? b.solution[i] : a.solution[i] for i in 1:len]),
    )
end


# ------------------- Numbers ------------------- 

function arithmetic_crossover(a::Individual, b::Individual)::Tuple{Individual, Individual}
    @assert (is_type(a.solution) == is_type(b.solution) == Numbers)
    α::Float64 = (1 - rand())
    return (
        Individual(a.solution .+ (α .* b.solution)),
        Individual(b.solution .+ (α .* a.solution)),
    )
end

function blend_crossover(a::Individual, b::Individual; α::Float64 = 0.5)::Tuple{Individual, Individual}
    @assert (is_type(a.solution) == is_type(b.solution) == Numbers)
    child_a::Vector{Float64} = []
    child_b::Vector{Float64} = []
    for i in 1:length(a.solution)
        hi, lo = (a.solution[i] > b.solution[i]) ? (a.solution[i], b.solution[i]) : (b.solution[i], a.solution[i])
        # We need to avoid multiplying by 0, if parents are equal
        d::Float64 = max(abs(hi-lo) * α, ϵ)
        x, y = rand(Uniform(lo - d, hi + d), 2)
        push!(child_a, x), push!(child_b, y) 
    end
    return Individual(child_a), Individual(child_b)
end


