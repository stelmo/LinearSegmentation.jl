"""
$(TYPEDSIGNATURES)

Partition `xs` into segments that are at least longer than `min_segment_length`,
and that have a fit better than `fit_threshold`. By default, the goodness-of-fit
is measured using the coefficient of determination. Each segment must have a
minimum R² of `fit_threshold`. Root mean squared error can also be used by
setting `fit_function = :rmse`, and adjusting `fit_threshold` to a dataset
dependent error threshold. In this case, the root mean squared error must be
smaller than `fit_threshold`.

Recursively splits the data into two parts with the best fit according to
`fit_function`, while obeying the minimum segment length restrictions from
`min_segment_length`, and goodness-off-fit restrictions from `fit_threshold`.
Sorts data internally as a precomputation step.  By default, the end of a
segment is also the start of the next segment, but this can be changed by
setting `overlap` to `false` (resulting in disjoint segmentations).

Returns an array of indices `[idxs1, ...]`, where `idxs1` are the indices of
`xs` in the first segment, etc.

# Example
```
segments = top_down(xs, ys; min_segment_length=1.2)
```

See also: [`sliding_window`](@ref), [`shortest_path`](@ref).
"""
function top_down(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    fit_threshold = 0.9,
    fit_function = :r2,
    overlap = true,
)
    segments = Vector{Vector{Int64}}()
    sxs = sortperm(xs) # do this once

    _top_down!(
        segments,
        xs,
        ys,
        sxs,
        1,
        length(xs),
        min_segment_length,
        fit_threshold,
        fit_function,
        overlap,
    )

    segments
end

function _top_down!(
    segments,
    xs,
    ys,
    sxs,
    start_idx,
    stop_idx,
    min_segment_length,
    fit_threshold,
    fit_function,
    overlap,
)


    brkpnt1 = _find_optimum_break_point(
        xs,
        ys,
        sxs,
        start_idx,
        stop_idx,
        min_segment_length,
        fit_function,
        overlap,
    )

    if isnothing(brkpnt1)
        push!(segments, sxs[start_idx:stop_idx])
        return nothing
    end

    brkpnt2 = overlap ? brkpnt1 : brkpnt1 + 1 # end/start overlap?

    _xs1 = xs[sxs[start_idx:brkpnt1]]
    _ys1 = ys[sxs[start_idx:brkpnt1]]
    ls1, threshold =
        fit_function == :r2 ?
        (-rsquared(_xs1, _ys1, least_squares(_xs1, _ys1)...), -fit_threshold) :
        (rmse(_xs1, _ys1, least_squares(_xs1, _ys1)...), fit_threshold)


    _xs2 = xs[sxs[brkpnt2:stop_idx]]
    _ys2 = ys[sxs[brkpnt2:stop_idx]]
    ls2 =
        fit_function == :r2 ? -rsquared(_xs2, _ys2, least_squares(_xs1, _ys1)...) :
        rmse(_xs2, _ys2, least_squares(_xs2, _ys2)...)

    if ls1 <= threshold || !is_min_length(_xs1, min_segment_length)
        push!(segments, sxs[start_idx:brkpnt1])
    else
        _top_down!(
            segments,
            xs,
            ys,
            sxs,
            start_idx,
            brkpnt1,
            min_segment_length,
            fit_threshold,
            fit_function,
            overlap,
        )
    end

    if ls2 <= threshold || !is_min_length(_xs2, min_segment_length)
        push!(segments, sxs[brkpnt2:stop_idx])
    else
        _top_down!(
            segments,
            xs,
            ys,
            sxs,
            brkpnt2,
            stop_idx,
            min_segment_length,
            fit_threshold,
            fit_function,
            overlap,
        )
    end

    nothing
end

function _find_optimum_break_point(
    xs,
    ys,
    sxs,
    start1_idx,
    stop2_idx,
    min_segment_length,
    fit_function,
    overlap,
)

    brkpnts = Int64[]
    losses = Float64[]
    for current_idx1 = start1_idx:stop2_idx
        current_idx2 = overlap ? current_idx1 : current_idx1 + 1
        current_idx2 == stop2_idx && break # done

        _xs1 = xs[sxs[start1_idx:current_idx1]]
        _xs2 = xs[sxs[current_idx2:stop2_idx]]

        # both segments need to have at least the minimum length
        is_min_length(_xs1, min_segment_length) || continue
        is_min_length(_xs2, min_segment_length) || break

        _ys1 = ys[sxs[start1_idx:current_idx1]]
        _ys2 = ys[sxs[current_idx2:stop2_idx]]

        # get minimum loss and break point
        v1 =
            fit_function == :r2 ? -rsquared(_xs1, _ys1, least_squares(_xs1, _ys1)...) :
            rmse(_xs1, _ys1, least_squares(_xs1, _ys1)...)
        v2 =
            fit_function == :r2 ? -rsquared(_xs2, _ys2, least_squares(_xs2, _ys2)...) :
            rmse(_xs2, _ys2, least_squares(_xs2, _ys2)...)

        push!(losses, min(v1, v2))
        push!(brkpnts, current_idx1)
    end

    isempty(losses) ? nothing : brkpnts[argmin(losses)]
end
