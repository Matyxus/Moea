include("../../src/Moea.jl")
using Main.Moea
# Objective function
f(x)::Float64 = -x[1] - x[2]
# Constrains
g1(x)::Float64 = -2*(x[1]^4) + 8*(x[1]^3) - 8*(x[1]^2) + x[2] - 2
g2(x)::Float64 = -4*(x[1]^4) + 32*(x[1]^3) - 88*(x[1]^2) + 96*x[1] + x[2] - 36
# Probblem definition
def::Definition = Definition("g24", Minimization, Numbers, 2)
opt::Optimization = Optimization(f, 1, [g1, g2], ((0, 0), (3, 4)))
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!)
run_algorithm(5000, nsga, "g24_nsga")
run_algorithm(5000, sr, "g24_sr")
