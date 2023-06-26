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
