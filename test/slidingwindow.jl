@testset "Sliding window tests" begin

    segs, fits = sliding_window(xs, ys; min_segment_length, max_rmse)

    @test length(segs) == 10
    @test isapprox(first(residuals(last(fits))), -0.02543526961307041; atol)
    @test N != length(reduce(vcat, [seg.idxs for seg in segs]))

    segs, fits = top_down(xs, ys; min_segment_length, max_rmse, overlap = false)
    @test N == length(reduce(vcat, [seg.idxs for seg in segs]))
end
