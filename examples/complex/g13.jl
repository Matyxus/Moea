include("../../src/Moea.jl")
using Main.Moea
# Objective function
f(x)::Float64 = exp(x[1] * x[2] * x[3] * x[4] * x[5])
# Constrains
h1(x)::Float64 = abs(x[1]^2 + x[2]^2 + x[3]^2 + x[4]^2 + x[5]^2 - 10) - ϵ
h2(x)::Float64 = abs(x[2]*x[3] - 5*x[4]*x[5]) - ϵ
h3(x)::Float64 = abs(x[1]^3 + x[2]^3 + 1) - ϵ
# Probblem definition
def::Definition = Definition("g13", Minimization, Numbers, 5)
opt::Optimization = Optimization(f, 1, [h1, h2, h3], ((-2.3, -2.3, -3.2, -3.2, -3.2), (2.3, 2.3, 3.2, 3.2, 3.2)))
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!)
run_algorithm(5000, nsga, "g13_nsga")
run_algorithm(5000, sr, "g13_sr")


