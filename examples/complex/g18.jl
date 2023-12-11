include("../../src/Moea.jl")
using Main.Moea
# Objective function
f(x)::Float64 = -0.5 * (x[1]*x[4] - x[2]*x[3] + x[3]*x[9] - x[5]*x[9] + x[5]*x[8] - x[6]*x[7])
# Constrains
g1(x)::Float64 = x[3]^2 + x[4]^2 - 1
g2(x)::Float64 = x[9]^2 - 1
g3(x)::Float64 = x[5]^2 + x[6]^2 - 1
g4(x)::Float64 = x[1]^2 + (x[3]-x[9])^2 - 1
g5(x)::Float64 = (x[1]-x[5])^2 + (x[2]-x[6])^2 - 1
g6(x)::Float64 = (x[1]-x[7])^2 + (x[2]-x[8])^2 -1
g7(x)::Float64 = (x[3]-x[5])^2 + (x[4]-x[6])^2 -1
g8(x)::Float64 = (x[3]-x[7])^2 + (x[4]-x[8])^2 -1
g9(x)::Float64 = x[7]^2 + (x[8]-x[9])^2 - 1
g10(x)::Float64 = x[2]*x[3] - x[1]*x[4]
g11(x)::Float64 = -x[3]*x[9]
g12(x)::Float64 = x[5]*x[9]
g13(x)::Float64 = x[6]*x[7] - x[5]*x[8]
# Probblem definition
def::Definition = Definition("g18", Minimization, Numbers, 9)
opt::Optimization = Optimization(
    f, 1, [g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11, g12, g13], 
    (
        (-10., -10., -10., -10., -10., -10., -10., -10., 0.), 
        (10., 10., 10., 10., 10., 10., 10., 10., 20.)
    )
)
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!, crossover_chance=0.8, mutation_chance=0.05)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!, crossover_chance=0.8)
run_algorithm(5000, nsga, "g18_nsga")
run_algorithm(5000, sr, "g18_sr")


