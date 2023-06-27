@testset "Types" begin
    seg = LinearSegmentation.Segment([1, 2, 3])
    @test all(seg.idxs .== [1, 2, 3])
end
