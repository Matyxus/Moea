import Distributions: Uniform
# ------------------- Permutation ------------------- 

"""
    pmx(a::Vector{Int64}, b::Vector{Int64})::Tuple{Vector{Int64}, Vector{Int64}}

    Performs crossover operation, by selecting two indexes then copies
    a[from:to] to the new solution, the rest is filled from "b".
    The absolute position of permutation numbers in "b" is kept as close as possible in 
    the new solution. This is done by creating mapping between a[from:to] and b[from:to].
    Similary starting with "b", the second solution in created.
    Operator only works for permutation representation.

# Arguments
- `a::Vector{Int64}`: First parent - solution
- `b::Vector{Int64}`: Second parent - solution

`Returns` Tuple containing newly generated solutions (permutations)
"""
function pmx(a::Vector{Int64}, b::Vector{Int64})::Tuple{Vector{Int64}, Vector{Int64}}
    @assert is_type(a) == is_type(b) == Permutation
    len::Int64 = length(a)
    from, to = rand(1:len, 2)
    from, to = from > to ? (to, from) : (from, to)

    function generate_child(A::Vector{Int64}, B::Vector{Int64})::Vector{Int64}
        child::Vector{Int64} = zeros(Int64, len)
        # Copy middle part from parent B
        child[from:to] = B[from:to]
        mapping::Dict{Int64, Int64} = Dict{Int64, Int64}(zip(child[from:to], A[from:to]))
        # Fill the missing permutation numbers from parents
        for i in vcat(1:from-1, to+1:len)
            item::Int64 = A[i]
            # There can be multiple mappings, iterate till its not present
            while (haskey(mapping, item))
                item = mapping[item]
            end
            child[i] = item
        end
        return child
    end
    return generate_child(a, b), generate_child(b, a)
end


# ------------------- Binary and Numbers ------------------- 

"""
    one_point_crossover(a::AbstractVector{T}, b::AbstractVector{T})::Tuple{AbstractVector{T}, AbstractVector{T}} where {T <: Real}

    Performs crossover operation, by randomly selecting index, 
    a[1:index] is combined with b[index+1:end] to create new solution (another using "b" first).
    Operator works for Binary and Numbers representations.

# Arguments
- `a::Individual`: First parent - solution
- `b::Individual`: Second parent - solution

`Returns` Tuple containing newly generated solutions (of either binary or numbers representation)
"""
function one_point_crossover(a::AbstractVector{T}, b::AbstractVector{T})::Tuple{AbstractVector{T}, AbstractVector{T}} where {T <: Real}
    @assert (is_type(a) == is_type(b) in [Numbers, Binary])
    crossover_point::Int64 = rand(1:(length(a)-1))
    return (
        append!(a[1:crossover_point],  b[crossover_point+1:end]),
        append!(b[1:crossover_point],  a[crossover_point+1:end])
    )
end

function uniform_crossover(a::AbstractVector{T}, b::AbstractVector{T})::Tuple{AbstractVector{T}, AbstractVector{T}} where {T <: Real}
    @assert (is_type(a) == is_type(b) in [Numbers, Binary])
    len::Int64 = length(a)
    mask::BitVector = bitrand(len)
    return [mask[i] ? a[i] : b[i] for i in 1:len], [mask[i] ? b[i] : a[i] for i in 1:len]
end


# ------------------- Numbers ------------------- 

function arithmetic_crossover(a::Vector{Real}, b::Vector{Real})::Tuple{Vector{Real}, Vector{Real}}
    @assert (is_type(a) == is_type(b) == Numbers)
    α::Float64 = (1 - rand())
    return (a .+ (α .* b)), (b .+ (α .* a))
end

function blend_crossover(a::Vector{Real}, b::Vector{Real}; α::Float64 = 0.5)::Tuple{Vector{Float64}, Vector{Float64}}
    @assert (is_type(a) == is_type(b) == Numbers)
    child_a::Vector{Float64} = []
    child_b::Vector{Float64} = []
    for i in 1:length(a)
        hi, lo = (a[i] > b[i]) ? (a[i], b[i]) : (b[i], a[i])
        # We need to avoid multiplying by 0, if parents are equal
        d::Float64 = max(abs(hi-lo) * α, ϵ)
        x, y = rand(Uniform(lo - d, hi + d), 2)
        push!(child_a, x), push!(child_b, y) 
    end
    return child_a, child_b
end


export pmx, one_point_crossover, uniform_crossover, arithmetic_crossover, blend_crossover

