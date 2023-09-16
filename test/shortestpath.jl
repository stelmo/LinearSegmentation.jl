@testset "Shortest path" begin
    #r2
    segments = shortest_path(xs, ys; min_segment_length)
    @test length(segments) == 4
    b0, b1 = LinearSegmentation.least_squares(xs[last(segments)], ys[last(segments)])
    @test isapprox(LinearSegmentation.rsquared(xs[last(segments)], ys[last(segments)], b0, b1), 0.9787001222049421; atol)

    # rmse
    segments = shortest_path(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
    )
    @test length(segments) == 4
    b0, b1 = LinearSegmentation.least_squares(xs[first(segments)], ys[first(segments)])
    @test isapprox(LinearSegmentation.rmse(xs[first(segments)], ys[first(segments)], b0, b1), 0.06440621325389449; atol)
    @test N != length(reduce(vcat, segments))

    segments = shortest_path(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
        overlap = false,
    )
    @test N == length(reduce(vcat, segments))
end
