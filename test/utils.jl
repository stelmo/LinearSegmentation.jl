@testset "Utils" begin

    xs = [1, 2, 3, 4, 5, 6]
    ys = [1.1, 1.9, 3.1, 4.2, 5.3, 5.9]

    b0, b1 = LinearSegmentation.least_squares(xs, ys)
    @test isapprox(b0, 0.0533333; atol)
    @test isapprox(b1, 1.0085714; atol)

    @test isapprox(LinearSegmentation.se(xs, ys, b0, b1), 0.1270476190476182; atol)
    @test isapprox(LinearSegmentation.rmse(xs, ys, b0, b1), 0.1455149585939639; atol)
    @test isapprox(LinearSegmentation.rsquared(xs, ys, b0, b1), 0.9929135845097545; atol)

    @test isapprox(LinearSegmentation.heuristic_min_segment_length(xs), 0.5; atol)

    @test !LinearSegmentation.is_min_length(xs[1:2], 3)
    @test LinearSegmentation.is_min_length(xs[1:2], 1)
end



