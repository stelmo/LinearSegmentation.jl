using LinearSegmentation
using Random
using CairoMakie, GLM

# settings
min_segment_length = 1.0
max_rmse = 0.10

# generate data
N = 100
xs = collect(range(0, 3 * pi, length = N)) .+ 0.1 .* randn(N)
ys = sin.(xs) .+ 0.1 .* randn(N)


# sliding_window
segs, fits = sliding_window(xs, ys; min_segment_length, max_rmse)

fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, xs, ys)

for (seg, fit) in zip(segs, fits)
    _xs = xs[seg.idxs]
    _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
    lines!(ax, _xs, _ys)
end
fig

# topdown
segs, fits = top_down(xs, ys; min_segment_length, max_rmse)

fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, xs, ys)

for (seg, fit) in zip(segs, fits)
    _xs = xs[seg.idxs]
    _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
    lines!(ax, _xs, _ys)
end
fig

# shortestpath (works less nicely on very noisy data)
segs, fits = graph_segmentation(xs, ys; min_segment_length, max_rmse = 0.1)

fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, xs, ys)

for (seg, fit) in zip(segs, fits)
    _xs = xs[seg.idxs]
    _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
    lines!(ax, _xs, _ys)
end
fig
