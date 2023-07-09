module LinearSegmentation

using DocStringExtensions, Statistics, GLM, Graphs

# Write your package code here.
include("utils.jl")
include("slidingwindow.jl")
# include("topdown.jl")
# include("shortestpath.jl")

export sliding_window,
    # top_down, 
    # shortest_path, 
    xygroups,
    xyboundgroups

end
