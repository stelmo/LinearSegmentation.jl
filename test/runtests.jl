using LinearSegmentation
using Test
using Random

using CairoMakie, GLM # for troubleshooting

include("generatedata.jl")

@testset "LinearSegmentation.jl" begin
    include("slidingwindow.jl")
end
