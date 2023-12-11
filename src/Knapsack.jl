import LinearAlgebra: dot

struct Knapsack
    num_items::Int64
    capacity::Union{Int64, Float64}
    weights::Vector{Int64}
    costs::Vector{Int64}
    Knapsack(num_items::Int64, capacity::Union{Int64, Float64}, weights::Vector{Int64}, costs::Vector{Int64}) = new(num_items, capacity, weights, costs)
    Knapsack(capacity::Union{Int64, Float64}, weights::Vector{Int64}, costs::Vector{Int64}) = new(length(weights), capacity, weights, costs)
end

function read_knapsack(file_name::String)::Union{Vector{Knapsack}, Nothing}
    if !file_exists(get_knapsack_path(file_name))
        return nothing
    end
    println("Reading file: $(get_knapsack_path(file_name))")
    knapsacks::Vector{Knapsack} = []
    open(get_knapsack_path(file_name), "r") do io
        num_knapsacks, num_items = read_params(io::IO)
        if isnothing(num_knapsacks) || isnothing(num_items)
            return nothing
        end
        if eof(io) || strip(readline(io)) != "="
            println("Expected 2nd line of file to be separtor: '=' !")
            return nothing
        end
        println("Number of knapsacks: $(num_knapsacks), number of items: $(num_items)")
        for i in 1:num_knapsacks 
            knapsack = read_knapsack(io, i)
            if isnothing(knapsack) || !(length(knapsack.weights) == length(knapsack.costs) == num_items)
                println("Invalid knapsack, or number if items not eqaul to: $(num_items)!")
                return nothing
            end
            println("Succesfully loaded knapsack: $(i)/$(num_knapsacks)")
            push!(knapsacks, knapsack)
        end
    end
    return knapsacks
end

function knapsack_to_problem(knapsacks::Vector{Knapsack}, name::String = "knapsack")::Problem
    # Transform knapsack into Problem
    if length(knapsacks) > 1
        return Problem(
            Definition(name, Maximization, Binary, knapsacks[1].num_items),
            Optimization(
                Function[x -> dot(x, knapsack.costs) for knapsack in knapsacks], length(knapsacks), 
                Function[x -> (dot(x, knapsack.weights) - knapsack.capacity) for knapsack in knapsacks] 
            )
        )
    end
    return knapsack_to_problem(knapsacks[1], name)
end

function knapsack_to_problem(knapsack::Knapsack, name::String = "knapsack")::Problem
    return Problem(
        Definition(name, Maximization, Binary, knapsack.num_items),
        Optimization(x -> dot(x, knapsack.costs), 1, x -> (dot(x, knapsack.weights) - knapsack.capacity))
    )
end

function load_pareto(pareto_file::String)::Union{Vector{Vector{Int64}}, Nothing}
    if !file_exists(get_knapsack_path(pareto_file))
        return nothing
    end
    dimension::Int64 = tryparse(Int64, split(pareto_file, ".")[end-1])
    file_name::String = get_knapsack_path(pareto_file)
    println("Reading file: $(file_name)")
    solutions::Vector{Vector{Int64}} = []
    open(file_name, "r") do io
        while !eof(io)
            line::String = strip(readline(io))
            values::Vector{String} = split(line)
            if length(values) == dimension
                push!(solutions, map(x -> tryparse(Int64, x), values))
            end
        end
    end
    return solutions
end


# ------------------ Utils ------------------ 

function read_params(io::IO)::Union{Tuple{Int64, Int64}, Tuple{Nothing, Nothing}}
    line = split(strip(readline(io)))
    if length(line) != 7 
        println("Expected first line to have 7 itesm, got: $(line)")
        return nothing, nothing
    elseif length(line[4]) < 2 || line[4][1] != '('
        println("Expected 4th item of line to be in format: '(Number', got: $(line[4])")
        return nothing, nothing
    end
    num_items::Union{Int64, Nothing} = tryparse(Int64, line[4][2:end])
    num_knapsacks::Union{Int64, Nothing} = tryparse(Int64, line[6])
    return num_items, num_knapsacks
end

function read_knapsack(io::IO, number::Int64)::Union{Knapsack, Nothing}
    # Check for knapsack
    if eof(io) || strip(readline(io)) != "knapsack $(number):"
        println("Expected line: 'knapsack $(number):'")
        return nothing
    end
    # Check for capacity
    capacity = read_param(io, "capacity:")
    if isnothing(capacity)
        return nothing
    end
    # Read items
    weights::Vector{Int64} = []
    costs::Vector{Int64} = []
    item::Int64 = 1
    while !eof(io)
        line = strip(readline(io))
        # Found separator
        if line == "=" || isempty(line)
            break
        elseif  line != "item $(item):"
            println("Expecte line: 'item $(item):', got: '$(line)'")
            return nothing
        end
        # Weight, Cost
        weight, cost = read_param(io, "weight:"), read_param(io, "profit:")
        if isnothing(weight) || isnothing(cost)
            println("Error while reading weight and/or cost of kanspack: $(number), item: $(item)")
            return nothing
        end
        push!(weights, weight)
        push!(costs, cost)
        item += 1
    end
    return Knapsack(capacity, weights, costs)
end

function read_param(io::IO, item_name::String)::Union{Nothing, Int64, Float64}
    if eof(io)
        println("Cannot param read: $(item_name) of knapsack, eof!")
        return nothing, nothing
    end
    line = split(strip(readline(io)))
    if length(line) != 2 || line[1] != "$(item_name)" || isnothing(tryparse(Int64, line[2])) && isnothing(tryparse(Float64, line[2]))
        println("Unable to read: '$(item_name)', incorrect line: $(line)")
        return nothing
    end
    return isnothing(tryparse(Int64, line[2])) ? tryparse(Float64, line[2]) : tryparse(Int64, line[2])
end


export Knapsack, read_knapsack, knapsack_to_problem, load_pareto
