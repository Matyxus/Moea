const SEP::String = Base.Filesystem.pathsep()
# -------------------- Data directory -------------------- 
const DATA_PATH::String = "data"
const KNAPSACK_PATH::String = DATA_PATH * SEP * "knapsack"
const LOGS_PATH::String  = DATA_PATH * SEP * "logs"
# -------------------- Extensions --------------------
const JSON_EXTENSION::String = ".json"
# -------------------- File functions -------------------- 
"""
    file_exists(file_path::String; messagge::Bool = true)::Bool

    Checkes whether file exists.

# Arguments
- `file_path::String`: path to file
- `messagge::Bool`: optional parameter, prints messagge about file not existing, true by default

`Returns` True if file exists, false otherwise.
"""
function file_exists(file_path::String; messagge::Bool = true)::Bool
    exists::Bool = isfile(file_path)
    if messagge && !exists
        Base.printstyled("File: '$(file_path)' does not exist!\n"; color = :red, blink = true)
        return false
    end
    return exists
end

# Functions returning full path to file (from its name) corresponding to type
get_knapsack_path(problem_name::String)::String = (KNAPSACK_PATH * SEP * problem_name)
get_log_path(log_name::String)::String = (LOGS_PATH * SEP * log_name * JSON_EXTENSION)

# --------------- Problem type --------------- 
abstract type ProblemType end
struct Minimization <: ProblemType end
struct Maximization <: ProblemType end
opposite_extrema(::Type{Minimization}) = Inf64
opposite_extrema(::Type{Maximization}) = -Inf64
# --------------- Representation --------------- 
abstract type Representation end
is_type(::Any)::Nothing = nothing 
struct Permutation <: Representation end
struct Binary <: Representation end
struct Numbers <: Representation end
is_type(val::Vector{Int64})::Union{Type{Permutation}, Type{Numbers}} = (Set(val) == Set(1:length(val))) ? Permutation : Numbers 
is_type(::Vector{Bool})::Type{Binary} = Binary 
is_type(::BitVector)::Type{Binary} = Binary 
is_type(::Bool)::Type{Binary} = Binary 
is_type(::Vector{Float64})::Type{Numbers} = Numbers
is_type(::Float64)::Type{Numbers} = Numbers
is_type(::Int64)::Type{Numbers} = Numbers

# --------------- Other --------------- 

const ϵ::Float64 = 0.0001

export ϵ, Permutation, Binary, Numbers, Minimization, Maximization, opposite_extrema
