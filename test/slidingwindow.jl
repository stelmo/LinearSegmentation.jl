@testset "Sliding window" begin
    # test r2
    segments = sliding_window(
        xs,
        ys;
        min_segment_length,
        # fit_threshold = 0.9,
    )

    @test length(segments) == 4
    @test isapprox(r2(last(last(segments))), 0.9926778131496851; atol)
    @test N != length(reduce(vcat, [first(seg) for seg in segments]))

    # test root mean square
    segments = sliding_window(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
    )

    @test length(segments) == 4
    @test isapprox(first(residuals(last(last(segments)))), -0.13477208456216216; atol)
    @test N != length(reduce(vcat, [first(seg) for seg in segments]))

    segments = sliding_window(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
        overlap = false,
    )
    @test N == length(reduce(vcat, [first(seg) for seg in segments]))
end
