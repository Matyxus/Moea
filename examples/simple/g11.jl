include("../../src/Moea.jl")
using Main.Moea
# Objective function
f(x)::Float64 = x[1]^2 + (x[2] - 1)^2
# Constrains
h(x)::Float64 = abs(x[2] - x[1]^2) - ϵ
# Probblem definition
def::Definition = Definition("g11", Minimization, Numbers, 2)
opt::Optimization = Optimization(f, 1, h, ((-1, -1), (1, 1)))
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!)
run_algorithm(5000, nsga, "g11_nsga")
run_algorithm(5000, sr, "g11_sr")
