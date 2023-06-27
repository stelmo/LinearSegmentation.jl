@testset "Utils" begin

    xs_short = [1, 2, 3, 4, 5, 6]
    ys_short = [1.1, 1.9, 3.1, 4.2, 5.3, 5.9]
    b0, b1 = LinearSegmentation.least_squares
    @test se(xs, ys)
end
