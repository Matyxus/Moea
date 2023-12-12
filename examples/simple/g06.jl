include("../../src/Moea.jl")
using Main.Moea
# Objective function
f(x) = (x[1] - 10)^3 + (x[2] - 20)^3
# Constrains
g1(x) = -(x[1] - 5)^2 - (x[2] - 5)^2 + 100
g2(x) = (x[1] - 6)^2 + (x[2] - 5)^2 - 82.81
def::Definition = Definition("g06", Minimization, Numbers, 2)
opt::Optimization = Optimization(f, 1, [g1, g2], ((13, 0), (100, 100)))
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!, crossover_chance=0.8, mutation_chance=0.05)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!, crossover_chance=0.3, mutation_chance=0.2)
run_algorithm(5000, nsga, "g06_nsga")
run_algorithm(5000, sr, "g06_sr")
