@testset "Top down tests" begin

    segs, fits = top_down(xs, ys; min_segment_length, max_rmse)

    @test length(segs) == 9
    @test isapprox(first(residuals(last(fits))), -0.04646376702868438; atol)
end
