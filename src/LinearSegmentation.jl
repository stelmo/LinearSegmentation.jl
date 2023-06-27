module LinearSegmentation

using DocStringExtensions, Statistics, GLM, Graphs

# Write your package code here.
include("types.jl")
include("utils.jl")
include("slidingwindow.jl")
include("topdown.jl")
include("graph_segmentation.jl")

export sliding_window,
    linear_segmentation,
    is_min_length,
    Segment,
    heuristic_min_segment_length,
    rmse,
    top_down,
    least_squares,
    graph_segmentation,
    build_digraph

end
