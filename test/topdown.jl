@testset "Top down" begin
    #r2
    segments = top_down(xs, ys; min_segment_length)
    @test length(segments) == 5
    b0, b1 = LinearSegmentation.least_squares(xs[last(segments)], ys[last(segments)])
    @test isapprox(LinearSegmentation.rsquared(xs[last(segments)], ys[last(segments)], b0, b1), 0.9926778131496851; atol)

    # rmse
    segments = top_down(xs, ys; min_segment_length, fit_threshold = max_rmse, fit_function = :rmse)
    @test length(segments) == 9
    b0, b1 = LinearSegmentation.least_squares(xs[first(segments)], ys[first(segments)])
    @test isapprox(LinearSegmentation.rmse(xs[first(segments)], ys[first(segments)], b0, b1), 0.023667594679358903; atol)
    @test N != length(reduce(vcat, segments))

    segments = top_down(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
        overlap = false,
    )
    @test N == length(reduce(vcat, segments))
end
