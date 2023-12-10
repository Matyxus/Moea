include("../../src/Moea.jl")
using Main.Moea
# Probblem definition
def::Definition = Definition("g21", Minimization, Numbers, 7)
# Objective function
f(x)::Float64 = x[1]
# Constrains
g1(x)::Float64 = -x[1] + 35*(sign(x[2]) * (abs(x[2])^0.6)) + 35*(sign(x[3]) * (abs(x[3])^0.6))
h1(x)::Float64 = abs(-300*x[3] + 7500*x[5] - 7500*x[6] - 25*x[4]*x[5] + 25*x[4]*x[6] + x[3]*x[4]) - ϵ
h2(x)::Float64 = abs(100*x[2] + 155.365*x[4] + 2500*x[7] - x[2]*x[4] - 25*x[4]*x[7] - 15536.5) - ϵ  
h3(x)::Float64 = abs(-x[5] + ((-x[4] + 900 < 0) ? opposite_extrema(def.problem_type) : log(-x[4] + 900))) - ϵ
h4(x)::Float64 = abs(-x[6] + ((x[4] + 300 < 0) ? opposite_extrema(def.problem_type) : log(x[4] + 300))) - ϵ
h5(x)::Float64 = abs(-x[7] + ((-2*x[4] + 700 < 0) ? opposite_extrema(def.problem_type) : log(-2*x[4] + 700))) - ϵ
# Probblem definition
opt::Optimization = Optimization(
    f, 1, [g1, h1, h2, h3, h4, h5], 
    (
        (0., 0., 0., 100., 6.3, 5.9, 4.5), 
        (1000., 40., 40., 300., 6.7, 6.4, 6.25)
    )
)
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!)
run_algorithm(5000, nsga, "g21_nsga")
run_algorithm(5000, sr, "g21_sr")


