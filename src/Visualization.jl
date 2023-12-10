using Plots

function plot_objective(f::Function, lb::Tuple, ub::Tuple, optimal::Union{Tuple, Nothing} = nothing, best::Union{Tuple, Nothing} = nothing)::Plots.Plot{Plots.GRBackend}
    x = range(lb[1], ub[1], length=1000)
    y = range(lb[2], ub[2], length=1000)
    objective_plot::Plots.Plot{Plots.GRBackend} = contour(x, y, (x, y) -> f([x, y]), color=:turbo, cbar=false, xlabel="x1", ylabel="x2")
    if !isnothing(optimal)
        scatter!(optimal, color = "red" , label = "optimal", markersize = 2)
    end
    if !isnothing(best)
        scatter!(best, color = "blue" , label = "best", markersize = 2)
    end
    title!("contours")
    return objective_plot
end


function plot_constrain(g::Function, lb::Tuple, ub::Tuple, title::String = "", optimal::Union{Tuple, Nothing} = nothing, best::Union{Tuple, Nothing} = nothing)::Plots.Plot{Plots.GRBackend}
    x = range(lb[1], ub[1], length=1000)
    y = range(lb[2], ub[2], length=1000)
    objective_plot::Plots.Plot{Plots.GRBackend} = contourf(x, y, (x, y) -> min(0, g([x, y])), color=:green, cbar=false, xlabel="x1", ylabel="x2")
    contourf!(x, y, (x,y) -> (g([x, y]) < 0) ? NaN : g([x, y]), color=:white, cbar=false)
    if !isnothing(optimal)
        scatter!(optimal, color = "red" , label = "optimal", markersize = 2)
    end
    if !isnothing(best)
        scatter!(best, color = "blue" , label = "best", markersize = 2)
    end
    title!(title)
    return objective_plot
end

function plot_result(log_name::String, optimal::Union{Real, Nothing} = nothing)::Union{Plots.Plot{Plots.GRBackend}, Nothing}
    if !file_exists(get_log_path(log_name))
        return nothing
    end
    data::Dict = load_log(log_name)
    if isempty(data)
        prinlnt("Data from log: $(log_name) are empty!")
        return nothing
    end
    result_plot::Plots.Plot{Plots.GRBackend} = scatter(data["data"][begin]["iteration"], data["data"][begin]["value"], color="blue", label="best", markersize = 2)
    if !isnothing(optimal)
        hline!(optimal, color="red", label="optimal", markersize = 2)
    end
    for i in 2:length(data["data"]) 
        scatter!(data["data"][i]["iteration"], data["data"][i]["value"], color="black", markersize = 1)
    end
    xlabel!("Iterations")
    ylabel!("Objective value")
    return result_plot
end

function plot_knapsack_result(log_name::String, pareto::String = "")::Union{Plots.Plot{Plots.GRBackend}, Nothing}
    if !file_exists(get_log_path(log_name))
        return nothing
    end
    data::Dict = load_log(log_name)
    if isempty(data)
        prinlnt("Data from log: $(log_name) are empty!")
        return nothing
    elseif data["problem"]["dimension"] != 2
        println("Can only show 2D knapsack problems!")
        return nothing
    end
    # Plot found results
    result_plot::Plots.Plot{Plots.GRBackend} = scatter(data["data"][begin]["solution"], color="blue", label="best", markersize = 2)
    for i in 2:length(data["data"]) 
        scatter!(data["data"][i]["solution"], color="black", label="", markersize = 1)
    end
    # Plot pareto fronts
    if !isempty(pareto)
        fronts = load_pareto(pareto)
        if !isnothing(fronts)
            scatter!(fronts, color="red", label="", markersize = 2)
        end
    end
    xlabel!("Objective value 1")
    ylabel!("Objective value 2")
    return result_plot
end

export plot_objective, plot_constrain, plot_result, plot_knapsack_result

