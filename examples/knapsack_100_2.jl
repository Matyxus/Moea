include("../src/Moea.jl")

knapsacks::Vector{Knapsack} = read_knapsack("knapsack.100.2")
prob::Problem = knapsack_to_problem(knapsacks, "knapsack.100.2")
nsga::NsgaII = NsgaII(
    prob, binary_init, 
    binary_tournament_selection,
    one_point_crossover, flip! 
)
temp = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
vals = rand(1:10, 5)
println(vals)
println(temp[vals])






