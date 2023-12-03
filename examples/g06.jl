include("../src/Moea.jl")
# Objective function
f(x) = (x[1] - 10)^3 + (x[2] - 20)^3
# Constrains
g1(x) = -(x[1] - 5)^2 - (x[2] - 5)^2 + 100
g2(x) = (x[1] - 6)^2 + (x[2] - 5)^2 - 82.81
# Bounds
b1(x) = (13 <= x[1] <= 100)
b2(x) = (0 <= x[2] <= 100)
def::Definition = Definition("g06", Minimization, Numbers, 2)
opt::Optimization = Optimization(f, 1, [g1, g2], ((13, 0), (100, 100)))
prob::Problem = Problem(def, opt)
nsga::NsgaII = NsgaII(prob, uniform_init, binary_tournament_selection, blend_crossover, normal_mutation!)
info(nsga)
