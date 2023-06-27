using LinearSegmentation
using Random
using CairoMakie, GLM, ColorSchemes

# settings
min_segment_length = 1.2
max_rmse = 0.15

# generate data
N = 100
xs = collect(range(0, 3 * pi, length = N)) .+ 0.1 .* randn(N)
ys = sin.(xs) .+ 0.1 .* randn(N)

fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, xs, ys; color=:black)
fig
CairoMakie.FileIO.save("imgs/data.png", fig)

# sliding_window
segs, fits = sliding_window(xs, ys; min_segment_length, max_rmse)

fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, xs, ys; color=:black)

for (i, (seg, fit)) in enumerate(zip(segs, fits))
    _xs = xs[seg.idxs]
    _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
    lines!(ax, _xs, _ys; color=ColorSchemes.tableau_10[i], linewidth=8)
end
fig
CairoMakie.FileIO.save("imgs/sliding_window.png", fig)

# topdown
segs, fits = top_down(xs, ys; min_segment_length, max_rmse)

fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, xs, ys; color=:black)

for (i, (seg, fit)) in enumerate(zip(segs, fits))
    _xs = xs[seg.idxs]
    _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
    lines!(ax, _xs, _ys; color=ColorSchemes.tableau_10[i], linewidth=8)
end
fig
CairoMakie.FileIO.save("imgs/top_down.png", fig)

# shortestpath (works less nicely on very noisy data)
segs, fits = graph_segmentation(xs, ys; min_segment_length, max_rmse)

fig = Figure()
ax = Axis(fig[1, 1])
scatter!(ax, xs, ys; color=:black)

for (i, (seg, fit)) in enumerate(zip(segs, fits))
    _xs = xs[seg.idxs]
    _ys = first(coef(fit)) .+ _xs .* last(coef(fit))
    lines!(ax, _xs, _ys; color=ColorSchemes.tableau_10[i], linewidth=8)
end
fig
CairoMakie.FileIO.save("imgs/graph_segmentation.png", fig)
