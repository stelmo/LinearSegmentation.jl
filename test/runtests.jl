using LinearSegmentation
using Test
using Random

using CairoMakie, GLM # for troubleshooting

# settings
min_segment_length = 1.0
max_rmse = 0.10

# generate test data
xs = collect(range(0, 3 * pi, length = N))
ys = sin.(xs)

@testset "LinearSegmentation.jl" begin
    include("slidingwindow.jl")
    include("topdown.jl")
    include("shortestpath.jl")
end
