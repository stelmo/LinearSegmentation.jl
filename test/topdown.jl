@testset "Top down tests" begin

    segs, fits = top_down(xs, ys; min_segment_length = 3.0, max_rmse = 0.10)

    fig = Figure()
    ax = Axis(fig[1, 1])
    scatter!(ax, xs, ys)

    for (seg, fit) in zip(segs, fits)
        _xs = xs[seg.idxs]
        _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
        lines!(ax, _xs, _ys)
    end
    fig

end
