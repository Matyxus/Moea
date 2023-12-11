include("../../src/Moea.jl")
using Main.Moea

optimum::Real = -5.50801327159536
plot = plot_result("g24_nsga", "g24_nsga", optimum)
savefig(plot, "g24_nsga_convergence")
