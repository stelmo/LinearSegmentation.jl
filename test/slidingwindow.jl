@testset "Sliding window tests" begin

    segs, fits = sliding_window(xs, ys; min_segment_length, max_rmse)

    @test length(segs) == 10
    @test isapprox(first(residuals(last(fits))), -0.02543526961307041; atol)
end
