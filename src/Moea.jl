using Revise
using Random
#module Moea
# Write your package code here.
#end
include("Representation.jl")
include("Problem.jl")
include("Mutation.jl")
include("Crossover.jl")
include("NsgaII.jl")

# Objective function
f(x) = (x[1] - 10)^3 + (x[2] - 20)^3
# Constrains
g1(x) = -(x[1] - 5)^2 - (x[2] - 5)^2 + 100
g2(x) = (x[1] - 6)^2 + (x[2] - 5)^2 - 82.81
# Bounds
b1(x) = (13 <= x[1] <= 100)
b2(x) = (0 <= x[2] <= 100)

println(typeof(((13, 0), (100, 100))))

#info(cts)
result = [2, 4]
# violation(Individual(result), cts)
temp::NTuple{2, Int64} = (1, 4)
println(result .<= temp)
println(is_type([1, 5.0]))

