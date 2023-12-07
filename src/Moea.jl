using Revise
using Random

Random.seed!(42)
#module Moea
# Write your package code here.
#end
# Structure definition
include("Constants.jl")
include("Problem.jl")
include("Individual.jl")
include("Knapsack.jl")
# Methods
include("Initialization.jl")
include("Selection.jl")
include("Mutation.jl")
include("Crossover.jl")
# Algorithm
include("NsgaII.jl")
include("StochasticRanking.jl")




