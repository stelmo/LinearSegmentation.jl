"""
$(TYPEDSIGNATURES)

Fit a linear model to the data.
"""
linear_segmentation(xs, ys) = lm([ones(length(xs)) xs], ys)

linear_segmentation(segment::Segment, xs, ys) =
    linear_segmentation(xs[segment.idxs], ys[segment.idxs])

linear_segmentation(segments::Array{Segment}, xs, ys) =
    [linear_segmentation(xs[segment.idxs], ys[segment.idxs]) for segment in segments]

"""
$(TYPEDSIGNATURES)

Return true if the interval is longer than `min_segment_length`.
"""
is_min_length(xs, min_segment_length) = abs(-(extrema(xs)...)) >= min_segment_length

"""
$(TYPEDSIGNATURES)

Guess an appropriate minimum segment length, which is the squareroot of the
standard deviation of `xs`.
"""
heuristic_min_segment_length(xs) = sqrt(std(xs))

"""
$(TYPEDSIGNATURES)

Root mean square error of a fit.
"""
rmse(fit) = sqrt(mean(residuals(fit) .^ 2))

"""
$(TYPEDSIGNATURES)

Calculate the least squares coefficients.
"""
function least_squares(xs, ys)
    ymean = mean(ys)
    xmean = mean(xs)
    b1 =
        sum((x - xmean) * (y - ymean) for (x, y) in zip(xs, ys)) /
        sum((x - xmean)^2 for x in xs)
    b0 = ymean - b1 * xmean
    b0, b1
end

"""
$(TYPEDSIGNATURES)

Root mean square error of a fit.
"""
rmse(xs, ys, b0, b1) = sqrt(se(xs, ys, b0, b1) / length(xs))

"""
$(TYPEDSIGNATURES)

Squared error of the fit (the residuals).
"""
se(xs, ys, b0, b1) = sum((y - b0 - b1 * x)^2 for (x, y) in zip(xs, ys))

"""
$(TYPEDSIGNATURES)

Return an array of tuples for each piecewise linear fit. Only the first and last
x and y pair is returned since the fit is a straight line.

# Example
```
segs, fits = graph_segmentation(xs, ys)
for (_xs, _ys) in xygroups(segs, fits, xs)
    lines!(ax, _xs, _ys) # Makie plotting
end
```

See also: [`xyboundgroups`](@ref).
"""
function xygroups(segs::Array{Segment}, fits, xs)
    ps = Vector{Tuple{Vector{Float64},Vector{Float64}}}()
    for (seg, lmfit) in zip(segs, fits)
        b0, b1 = coef(lmfit)
        _xs = xs[seg.idxs][[1, end]]
        _ys = b0 .+ b1 .* _xs
        push!(ps, (_xs, _ys))
    end
    ps
end

"""
$(TYPEDSIGNATURES)

Return an array of tuples for each piecewise linear fit. The full segment is
returned, as well as the lower and upper bounds for the fit at these points.
Forwards the kwargs to `GLM.StatsAPI.predict` to modify the type of bound
information returned.

# Example
```
segs, fits = graph_segmentation(xs, ys)
for (_xs, _ys, _lbs, _ubs) in xyboundgroups(segs, fits, xs)
    lines!(ax, _xs, _ys) # Makie plotting
    band!(ax, _xs, _lbs, _ubs)
end
```

See also: [`xygroups`](@ref).
"""
function xyboundgroups(segs, fits, xs; interval = :prediction, level = 0.95)
    ps = Vector{Tuple{Vector{Float64},Vector{Float64},Vector{Float64},Vector{Float64}}}()
    for (seg, lmfit) in zip(segs, fits)
        _xs = xs[seg.idxs]
        xybnds = predict(lmfit, [ones(length(_xs)) _xs]; interval, level)
        push!(ps, (_xs, xybnds.prediction, xybnds.lower, xybnds.upper))
    end
    ps
end
