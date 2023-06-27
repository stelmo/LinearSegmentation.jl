module LinearSegmentation

using DocStringExtensions, Statistics, GLM, Graphs

# Write your package code here.
include("types.jl")
include("utils.jl")
include("slidingwindow.jl")
include("topdown.jl")
include("graph_segmentation.jl")

export sliding_window, top_down, graph_segmentation

end
