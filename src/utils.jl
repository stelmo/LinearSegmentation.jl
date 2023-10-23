
"""
$(TYPEDSIGNATURES)

Return true if the interval is longer than `min_segment_length`.
"""
is_min_length(xs, min_segment_length) = abs(-(extrema(xs)...)) >= min_segment_length

"""
$(TYPEDSIGNATURES)

Guess an appropriate minimum segment length, which the length of `xs` divided by
10.
"""
heuristic_min_segment_length(xs) = abs(-(extrema(xs)...)) / 10

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

Calculate the coefficient of determination (R²) for a linear fit of `b0`, `b1`
on `xs` and `ys`.
"""
function rsquared(xs, ys, b0, b1)
    ymean = mean(ys)
    1 - sum((y - b0 - b1 * x)^2 for (x, y) in zip(xs, ys)) / sum((y - ymean)^2 for y in ys)
end

"""
$(TYPEDSIGNATURES)

Fit a straight line between the endpoints of `xs` and `ys`. 
"""
function endpoints(xs, ys)

    x0 = first(xs)
    y0 = first(ys)

    xn = last(xs)
    yn = last(ys)

    A = [x0 1;xn 1]
    b = [y0, yn]
    b1, b0 = A\b

    b0, b1
end