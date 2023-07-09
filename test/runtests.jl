using LinearSegmentation
using Test
using Random
using Graphs, GLM

# test settings
atol = 1e-6

# settings
min_segment_length = 1.0
max_rmse = 0.10

# generate test data
N = 100
xs = collect(range(0, 3 * pi, length = N))
ys = sin.(xs)

@testset "LinearSegmentation.jl" begin
    @testset "Internals" begin
        include("types.jl")
        include("utils.jl")
    end

    @testset "Segmentation " begin
        include("slidingwindow.jl")
        include("topdown.jl")
        include("shortestpath.jl")
    end
end
