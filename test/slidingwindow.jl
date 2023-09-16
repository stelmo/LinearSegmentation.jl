@testset "Sliding window" begin
    # test r2
    segments = sliding_window(
        xs,
        ys;
        min_segment_length,
        # fit_threshold = 0.9,
    )

    @test length(segments) == 4
    b0, b1 = LinearSegmentation.least_squares(xs[last(segments)], ys[last(segments)])
    @test isapprox(
        LinearSegmentation.rsquared(xs[last(segments)], ys[last(segments)], b0, b1),
        0.9926778131496851;
        atol,
    )
    @test N != length(reduce(vcat, segments))

    # test root mean square
    segments = sliding_window(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
    )

    @test length(segments) == 4
    b0, b1 = LinearSegmentation.least_squares(xs[first(segments)], ys[first(segments)])
    @test isapprox(
        LinearSegmentation.rmse(xs[first(segments)], ys[first(segments)], b0, b1),
        0.09975406785624195;
        atol,
    )
    @test N != length(reduce(vcat, segments))

    segments = sliding_window(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
        overlap = false,
    )
    @test N == length(reduce(vcat, segments))
end
