"""
$(TYPEDSIGNATURES)

Segment `xs` into sections, which are at least longer than `min_segment_length`,
and that have a root mean squared error (based on a linear fit) less than
`max_rmse`. Uses a sliding window approach to segment the data: initially an
empty segment is made, and data added to it until `max_rmse` is reached. Then a
new segment is made, and the process repeats until the data is exhausted.

Sorts data internally as a precomputation step. Fastest segmentation algorithm
implemented, but also the least accurate.

Returns an array of [`Segment`](@ref)s and an array of `LinearModel`s from
GLM.jl corresponding to these segments.

# Example
```
segs, fits = sliding_window(xs, ys; min_segment_length=1.2, max_rmse=0.15)
```

See also: [`top_down`](@ref), [`shortest_path`](@ref).
"""
function sliding_window(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    max_rmse = 0.5,
    overlap = true,
)
    sxs = sortperm(xs) # increasing order

    segments = Segment[]

    start_idx = 1
    for current_idx = 2:length(sxs)
        _xs = xs[sxs[start_idx:current_idx]]
        _ys = ys[sxs[start_idx:current_idx]]

        is_min_length(_xs, min_segment_length) || continue

        lmfit = rmse(_xs, _ys, least_squares(xs, ys)...)
        if lmfit >= max_rmse
            push!(segments, Segment(sxs[start_idx:(current_idx-1)]))
            start_idx = overlap ? current_idx - 1 : current_idx # start is previous end
        end
    end

    # clean up
    push!(segments, Segment(sxs[start_idx:end]))

    segments, linear_segmentation(segments, xs, ys)
end
