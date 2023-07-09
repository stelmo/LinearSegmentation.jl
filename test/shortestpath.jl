@testset "Graph segmentation" begin

    segs, fits = shortest_path(xs, ys; min_segment_length, max_rmse)

    @test length(segs) == 7
    @test isapprox(first(residuals(last(fits))), -0.04646376702868438; atol)
    @test N != length(reduce(vcat, [seg.idxs for seg in segs]))

    segs, fits = shortest_path(xs, ys; min_segment_length, max_rmse, overlap=false)
    @test N == length(reduce(vcat, [seg.idxs for seg in segs]))
end
