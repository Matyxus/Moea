include("../../src/Moea.jl")
using Main.Moea
knapsacks::Vector{Knapsack} = read_knapsack("knapsack.100.3")
prob::Problem = knapsack_to_problem(knapsacks, "knapsack.100.3")
nsga::NsgaII = NsgaII(
    prob, binary_init, 
    binary_tournament_selection,
    uniform_crossover, flip! 
)
run_algorithm(5000, nsga, "knapsack_100_3")
