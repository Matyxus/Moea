include("../src/Moea.jl")

knapsacks::Vector{Knapsack} = read_knapsack("knapsack.100.2")
prob::Problem = knapsack_to_problem(knapsacks, "knapsack.100.2")
nsga::NsgaII = NsgaII(
    prob, binary_init, 
    binary_tournament_selection,
    one_point_crossover, flip! 
)
for _ in 1:999 
    step(nsga)
end
step(nsga)






