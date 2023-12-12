include("../../src/Moea.jl")
using Main.Moea
# Probblem definition
def::Definition = Definition("g08", Minimization, Numbers, 2)
# Objective function
function f(x)::Float64
    # Handle 0/0 -> NaN case
    value::Float64 = - ((sin(2*π*x[1])^3) * (sin(2*pi*x[2]))) / ((x[1]^3) * (x[1] + x[2]))
    return isnan(value) ? opposite_extrema(def.problem_type) : value
end
# Constrains
g1(x)::Float64 = x[1]^2 - x[2] + 1
g2(x)::Float64 = 1 - x[1] + (x[2] - 4)^2
# Structures
opt::Optimization = Optimization(f, 1, [g1, g2], ((0, 0), (10, 10)))
prob::Problem = Problem(def, opt)
# Algorithms
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!, crossover_chance=0.8, mutation_chance=0.05)
sr::StochasticRanking = StochasticRanking(prob, uniform_init, tournament_selection, blend_crossover, normal_mutation!, crossover_chance=0.3, mutation_chance=0.2)
# Run
run_algorithm(5000, nsga, "g08_nsga")
run_algorithm(5000, sr, "g08_sr")

