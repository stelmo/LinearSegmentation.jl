@testset "Graph segmentation" begin

    segs, fits = graph_segmentation(xs, ys; min_segment_length, max_rmse)

    @test length(segs) == 7
    @test isapprox(first(residuals(last(fits))), -0.04646376702868438; atol)
end
