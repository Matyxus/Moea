include("../../src/Moea.jl")
using Main.Moea

results::Vector{NTuple{2, String}} = [
    ("g06_nsga", "g06_sr"),
    ("g08_nsga", "g08_sr"),
    ("g11_nsga", "g11_sr"),
    ("g13_nsga", "g13_sr"),
    ("g18_nsga", "g18_sr"),
    ("g24_nsga", "g24_sr")
]
optimums::Vector{Real} = [
    -6961.813875, # g06
    -0.095825, # g08
    0.7499, # g11
    0.053941, # g13,
    -0.866025, # g18
    -5.508013 #g24
]

for (result_files, optimum) in zip(results, optimums)
    for file in result_files
        plot = plot_result(file, file, optimum)
        savefig(plot, file * "_convergence")
    end 
end




