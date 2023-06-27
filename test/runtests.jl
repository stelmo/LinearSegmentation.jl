using LinearSegmentation
using Test
using Random
using Graphs, GLM

# settings
min_segment_length = 1.0
max_rmse = 0.10

# generate test data
xs = collect(range(0, 3 * pi, length = N))
ys = sin.(xs)

@testset "LinearSegmentation.jl" begin
    include("types.jl")
    include("utils.jl")
    include("slidingwindow.jl")
    include("topdown.jl")
    include("graph_segmentation.jl")
end
