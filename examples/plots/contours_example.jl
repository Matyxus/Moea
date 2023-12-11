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

optimal::Tuple = (2.32952019747762, 3.17849307411774)
best::Tuple =  (2.329520164828056, 3.178492575044285)
plot = plot_constrain(x -> max(g1(x), g2(x)), opt.bounds[1], opt.bounds[2], "g1 & g2", optimal, best)
savefig(plot, "contours_constrain_g1g2_g24.png")
