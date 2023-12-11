include("../../src/Moea.jl")
using Main.Moea

results::Vector{String} = ["knapsack_100_2", "knapsack_250_2", "knapsack_500_2"]

for result in results
    name::String = replace(result, "_" => ".")
    plot = plot_knapsack_result(result, name, name * ".pareto")
    savefig(plot, result * "_convergence")
end




