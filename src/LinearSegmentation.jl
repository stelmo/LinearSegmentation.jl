module LinearSegmentation

using DocStringExtensions, Statistics, GLM

# Write your package code here.
include("types.jl")
include("utils.jl")
include("slidingwindow.jl")
include("topdown.jl")
# include("bottomup.jl")
# include("dynprog.jl")

export sliding_window,
    linear_segmentation,
    is_min_length,
    Segment,
    heuristic_min_segment_length,
    rmse,
    _find_optimum_break_point,
    top_down,
    _top_down!

end
