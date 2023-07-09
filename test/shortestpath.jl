@testset "Shortest path" begin
    #r2
    segments = shortest_path(xs, ys; min_segment_length)
    @test length(segments) == 4
    @test isapprox(r2(last(last(segments))), 0.9787001222049421; atol)

    # rmse
    segments = shortest_path(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
    )
    @test length(segments) == 4
    @test isapprox(first(residuals(last(last(segments)))), -0.13477208456216216; atol)
    @test N != length(reduce(vcat, [first(seg) for seg in segments]))

    segments = shortest_path(
        xs,
        ys;
        min_segment_length,
        fit_threshold = max_rmse,
        fit_function = :rmse,
        overlap = false,
    )
    @test N == length(reduce(vcat, [first(seg) for seg in segments]))
end
