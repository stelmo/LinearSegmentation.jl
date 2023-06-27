@testset "Sliding window tests" begin

    segs, fits = sliding_window(xs, ys; min_segment_length, max_rmse)

    @test length(segs) == 4
    @test isapprox(first(residuals(last(fits))), -0.13477208456216216; atol)
end
