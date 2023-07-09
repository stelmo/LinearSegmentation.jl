"""
$(TYPEDSIGNATURES)

Segment `xs` based on the root mean square error of a linear fit using `ys`.
Recursively splits the data into two parts with the lowest root mean square
error, while obeying the minimum segment length restrictions from
`min_segment_length`, and maximum allowed error from `max_rmse`. Sorts data
internally as a precomputation step.  By default, the end of a segment is also
the start of the next segment, but this can be changed by setting `overlap` to
`false` (resulting in disjoint segmentations).

Returns an array of [`Segment`](@ref)s, and an array of `LinearModel`s from
GLM.jl corresponding to these segments.

# Example
```
segs, fits = top_down(xs, ys; min_segment_length=1.2, max_rmse=0.15)
```

See also: [`sliding_window`](@ref), [`shortest_path`](@ref).
"""
function top_down(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    max_rmse = 0.5,
    overlap = true,
)
    segments = Segment[]
    sxs = sortperm(xs) # do this once

    _top_down!(segments, xs, ys, sxs, 1, length(xs), min_segment_length, max_rmse, overlap)

    segments, linear_segmentation(segments, xs, ys)
end

function _top_down!(
    segments,
    xs,
    ys,
    sxs,
    start_idx,
    stop_idx,
    min_segment_length,
    max_rmse,
    overlap,
)


    brkpnt1 = _find_optimum_break_point(
        xs,
        ys,
        sxs,
        start_idx,
        stop_idx,
        min_segment_length,
        overlap,
    )

    if isnothing(brkpnt1)
        push!(segments, Segment(sxs[start_idx:stop_idx]))
        return nothing
    end

    brkpnt2 = overlap ? brkpnt1 : brkpnt1 + 1 # end/start overlap?

    _xs1 = xs[sxs[start_idx:brkpnt1]]
    _ys1 = ys[sxs[start_idx:brkpnt1]]
    ls1 = rmse(_xs1, _ys1, least_squares(_xs1, _ys1)...)

    _xs2 = xs[sxs[brkpnt2:stop_idx]]
    _ys2 = ys[sxs[brkpnt2:stop_idx]]
    ls2 = rmse(_xs2, _ys2, least_squares(_xs2, _ys2)...)

    if ls1 <= max_rmse || !is_min_length(_xs1, min_segment_length)
        push!(segments, Segment(sxs[start_idx:brkpnt1]))
    else
        _top_down!(
            segments,
            xs,
            ys,
            sxs,
            start_idx,
            brkpnt1,
            min_segment_length,
            max_rmse,
            overlap,
        )
    end

    if ls2 <= max_rmse || !is_min_length(_xs2, min_segment_length)
        push!(segments, Segment(sxs[brkpnt2:stop_idx]))
    else
        _top_down!(
            segments,
            xs,
            ys,
            sxs,
            brkpnt2,
            stop_idx,
            min_segment_length,
            max_rmse,
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
        push!(
            losses,
            min(
                rmse(_xs1, _ys1, least_squares(_xs1, _ys1)...),
                rmse(_xs2, _ys2, least_squares(_xs2, _ys2)...),
            ),
        )
        push!(brkpnts, current_idx1)
    end

    isempty(losses) ? nothing : brkpnts[argmin(losses)]
end
