@testset "Sliding window tests" begin

    segs, fits = sliding_window(xs, ys; min_segment_length = 5.0, max_rmse = 0.01, dx = 0.5)

    fig = Figure()
    ax = Axis(fig[1, 1])
    scatter!(ax, xs, ys)

    for (seg, fit) in zip(segs, fits)
        _xs = xs[seg.start_idx:seg.end_idx]
        _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
        lines!(ax, _xs, _ys)
    end
    fig

end
