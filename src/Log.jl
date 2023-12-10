import JSON: print as j_print
"""
Structure saving results of algorithms
in vector of tuples: (iteration, solution, objecetive value)
"""
struct Log
    cache::Vector{Tuple{Int64, Vector, Union{Real, Vector}}}
    Log() = new([])
end


"""
    add_result(log::Log, iteration::Int64, distance::Float64, solution::Vector{Int64})

    Stores the current result inside Log structure.

# Arguments
- `log::Log`: structure saving results
- `iteration::Int64`: iteration at which result was found
- `indiv::Individual`: best inidividual of current population

`Returns` the current stored results
"""
add_result(log::Log, iteration::Int64, indiv::Individual) = push!(log.cache, (iteration, indiv.solution, indiv.value))


"""
    save_log(file_name::String, data::Dict, log::Log)::Bool

    Creates JSON file inside 'data/logs' directory.

# Arguments
- `file_name::String`: name of file solution will be saved in
- `problem::Problem`: definition of problem
- `log::Log`: structure saving results

`Returns` true on success, false otherwise
"""
function save_log(file_name::String, problem::Problem, log::Log)::Bool
    # Checks
    if isempty(log.cache)
        println("Data are empty, nothing to be saved!")
        return false
    end
    # Save results, from best to worst (so that best one can be seen immediately)
    data::Dict = Dict(
        "info" => Dict(
            "name" => problem.definition.name,
            "dimension" => problem.optimization.num_objectives,
            "iterations" => log.cache[end][begin],
            "type" => nameof(problem.definition.problem_type)
        ),
        "data" => [
            Dict(
                "iteration" => solution[1],
                "solution" => solution[2],
                "value" => solution[3]
            ) for solution in reverse(log.cache)
        ]
    )
    # Move to "logs" folder and add extension
    file_name = isempty(file_name) ? "log" : file_name
    file_name = (LOGS_PATH * SEP * file_name * JSON_EXTENSION)
    if file_exists(file_name; messagge=false)
        println("File: '$(file_name)' already exists!")
        return false
    end
    println("Saving log to file: '$(file_name)'")
    # Save data to file
    open(file_name, "w") do f
        j_print(f, data, 2)
    end
    return true 
end


"""
    function load_config(config_name::String)::Union{Dict, Nothing}

    Loads the (JSON) result/log file from '/data/logs' directory.

# Arguments
- `log_name::String`: name of the results (log) file

`Returns` Dictionary representing saved result (JSON) file or nothing if file does not exist
"""
function load_log(log_name::String)::Union{Dict, Nothing}
    log_path::String = get_log_path(log_name)
    if !file_exists(log_path)
        return nothing
    end
    return parsefile(log_path)
end

export Log, save_log, load_log, add_result



