using Revise
using Random
Random.seed!(42)
#module Moea
# Write your package code here.
#end
include("Constants.jl")
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
result = [2., 4.]
result2 = [4., 8.]
def::Definition = Definition("g06", Minimization, Numbers)
opt::Optimization = Optimization(f, g1, ((13, 0), (100, 100)))
prob::Problem = Problem(def, opt)
info(prob)
indiv::Individual = Individual(result, f(result))
indiv2::Individual = Individual(result2, f(result2))
println(domination(Maximization, indiv, indiv2))
evaluate!(indiv, opt)
println(indiv)
println(g1(result), g2(result2))
# println(bound_violation(result, opt.bounds))
# println(bound_violation(1, ((-5,), (-1.5,))))
# indiv.solution = indiv.solution  + rand(Normal(0, 0.2), 2)



