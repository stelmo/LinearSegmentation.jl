@testset "Top down tests" begin
    #r2
    segments = top_down(xs, ys; min_segment_length)
    @test length(segments) == 5
    @test isapprox(r2(last(last(segments))), 0.9926778131496851; atol)

    # rmse
    segments = top_down(xs, ys; min_segment_length, fit_threshold = max_rmse, fit_function=:rmse)
    @test length(segments) == 9
    @test isapprox(first(residuals(last(last(segments)))), -0.04646376702868438; atol)
    @test N != length(reduce(vcat, [first(seg) for seg in segments]))

    segments = top_down(xs, ys; min_segment_length, fit_threshold = max_rmse, fit_function=:rmse, overlap = false)
    @test N == length(reduce(vcat, [first(seg) for seg in segments]))
end
