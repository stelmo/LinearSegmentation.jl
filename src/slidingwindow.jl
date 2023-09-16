"""
$(TYPEDSIGNATURES)

Partition `xs` into segments that are at least longer than `min_segment_length`,
and that have a fit better than `fit_threshold`. By default, the goodness-of-fit
is measured using the coefficient of determination. Each segment must have a
minimum R² of `fit_threshold`. Root mean squared error can also be used by
setting `fit_function = :rmse`, and adjusting `fit_threshold` to a dataset
dependent error threshold. In this case, the root mean squared error must be
smaller than `fit_threshold`.

Uses a sliding window approach to segment the data: initially an empty segment
is made, and data added to it until `fit_threshold` is reached. Then a new
segment is made, and the process repeats until the data is exhausted.  By
default, the end of a segment is also the start of the next segment, but this
can be changed by setting `overlap` to `false` (resulting in disjoint
segmentations). 

Sorts data internally as a precomputation step. Fastest segmentation algorithm
implemented, but also the least accurate.

Returns an array of indices `[idxs1, ...]`, where `idxs1` are the indices of
`xs` in the first segment, etc.

# Example
```
segments = sliding_window(xs, ys; min_segment_length=1.2, fit_threshold=0.9)
```

See also: [`top_down`](@ref), [`shortest_path`](@ref).
"""
function sliding_window(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    fit_threshold = 0.9,
    fit_function = :r2,
    overlap = true,
)
    sxs = sortperm(xs) # increasing order

    segments = Vector{Vector{Int64}}()

    start_idx = 1
    for current_idx = 2:length(sxs)
        _xs = xs[sxs[start_idx:current_idx]]
        _ys = ys[sxs[start_idx:current_idx]]

        is_min_length(_xs, min_segment_length) || continue

        lmfit, threshold =
            fit_function == :r2 ?
            (-rsquared(_xs, _ys, least_squares(_xs, _ys)...), -fit_threshold) :
            (rmse(_xs, _ys, least_squares(_xs, _ys)...), fit_threshold)

        if lmfit >= threshold
            push!(segments, sxs[start_idx:(current_idx-1)])
            start_idx = overlap ? current_idx - 1 : current_idx # start is previous end
        end
    end

    # clean up
    push!(segments, sxs[start_idx:end])

    segments
end
