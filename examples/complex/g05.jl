include("../../src/Moea.jl")
using Main.Moea
# Objective function
f(x)::Float64 = 3*x[1] + 0.000001 * (x[1]^3) + 2*x[2] + (0.000002/3) * (x[2]^3)
# Constrains
g1(x)::Float64 = -x[4] + x[3] - 0.55
g2(x)::Float64 = -x[3] + x[4] - 0.55
h1(x)::Float64 = abs(1000*sin(-x[3] - 0.25) + 1000*sin(-x[4] - 0.25) + 894.8 - x[1]) - ϵ
h2(x)::Float64 = abs(1000*sin(x[3] - 0.25) + 1000*sin(x[3] - x[4] - 0.25) + 894.8 - x[2]) - ϵ
h3(x)::Float64 = abs(1000*sin(x[4] - 0.25) + 1000*sin(x[4] - x[3] - 0.25) + 1294.8) - ϵ
# Probblem definition
def::Definition = Definition("g05", Minimization, Numbers, 4)
opt::Optimization = Optimization(f, 1, [g1, g2, h1, h2, h3], ((0., 0., -0.55, -0.55), (1200., 1200., 0.55, 0.55)))
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!)
run_algorithm(5000, nsga, "g05_nsga")
run_algorithm(5000, sr, "g05_sr")
