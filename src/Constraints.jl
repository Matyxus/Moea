struct Constraints
    # Constraints
    G::Function
    num_constraints::Int64
    # Bounds
    B::Union{Nothing, Vector{Tuple{Real, Real}}}
    num_bounds::Int64
    Constraints(G::Union{Function, Vector{Function}}) = new(
        (isa(G, Vector) ? (x -> (|>).(Ref(x), G), length(G)) : (G, 1))...,
        nothing, 0
    )
    Constraints(G::Union{Function, Vector{Function}}, B::Vector{Tuple{V, V}}) where {V <: Real} = new(
        (isa(G, Vector) ? (x -> (|>).(Ref(x), G), length(G)) : (G, 1))...,
        B, length(B)
    )
end

function info(cts::Constraints)
    println("Constraints count: $(cts.num_constraints), bounds: $(cts.num_bounds)")
    println("Constraints: $(cts.G), bounds: $(cts.B)")
end


function violation(indiv::Individual, constrains::Constraints)::Real
    @assert (length(indiv.solution) == constrains.num_bounds)
    # First evaluate constrains
    g_violations::Union{Vector{Float64}} = abs.(constrains.G(indiv.solution))
    println("Constrain violation: $(g_violations)")
    # We need to switch comparison from '<=' to '>=' to allow for multiplication
    result::Float64 = sum(g_violations .* (g_violations .>= 0))
    println("Sum constrain violation: $(result)")
    # After evaluate bounds
    if !isnothing(constrains.B)
        println("Computing bounds violation")
        println("Solution: $(indiv.solution)")
        println("Lower: $(constrains.B[1, :])")
        println()
       #  lower::Vector{Float64} = indiv.solution .- (constrains.B[1, :] * (indiv.solution .<= constrains.B[1, :]))
        # println("Lower bounds violation: $(lower)")
        # result += sum(bound_violations .* (constrains.bounds[1, :] .<= bound_violations .<= constrains.bounds[2, :]))
    end

    # solution.violation = g_violation + bound_violation
    return 0
end



