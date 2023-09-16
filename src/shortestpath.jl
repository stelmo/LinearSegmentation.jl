"""
$(TYPEDSIGNATURES)

Partition `xs` into segments that are at least longer than `min_segment_length`,
and that have a fit better than `fit_threshold`. By default, the goodness-of-fit
is measured using the coefficient of determination. Each segment must have a
minimum R² of `fit_threshold`. Root mean squared error can also be used by
setting `fit_function = :rmse`, and adjusting `fit_threshold` to a dataset
dependent error threshold. In this case, the root mean squared error must be
smaller than `fit_threshold`.

Builds a directed graph where nodes are the x-data points, and the edge weights
are the goodness-of-fit measure associated with a linear model between these
nodes. Nodes are connected only if their minimum length is greater than
`min_segment_length`, and the goodness-of-fit better than `fit_threshold`. By
default, the end of a segment is also the start of the next segment, but this
can be changed by setting `overlap` to `false` (resulting in disjoint
segmentations). Thereafter, the shortest weighted path spanning the entire
dataset is found using the A-star algorithm. This more-or-less corresponds to
the dynamic programming approach used by other segmentation algorithms. 

Sorts data internally as a precomputation step. This is the slowest algorithm,
but should return a segmentation where the segments are as long as possible,
balanced against their fit.

Returns an array of indices `[idxs1, ...]`, where `idxs1` are the indices of
`xs` in the first segment, etc.

# Example
```
segments = shortest_path(xs, ys; min_segment_length=1.2)
```

See also: [`sliding_window`](@ref), [`top_down`](@ref).
"""
function shortest_path(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    fit_threshold = 0.9,
    fit_function = :r2,
    overlap = true,
)

    len_xs = length(xs)
    segments = Vector{Vector{Int64}}()
    sxs = sortperm(xs) # do this once

    g, w = build_digraph(
        xs[sxs],
        ys[sxs],
        min_segment_length,
        fit_threshold,
        fit_function,
        overlap,
    )

    path_edges = a_star(g, 1, len_xs, w)
    for edge in path_edges
        i = edge.src
        j = edge.dst
        if overlap
            jj = j
        else
            jj = j == len_xs ? j : j - 1
        end
        push!(segments, sxs[i:jj])
    end

    segments
end

"""
$(TYPEDSIGNATURES)

Build a directed graph where each node represents an index, and edges are
segments that link indices. Enumerates all possible segments that are at least
`min_segment_length` long. Weights are assigned by mean squared error of the
linear fit. If rmse is bigger than `max_rmse`, then weight is set to `Inf`.
"""
function build_digraph(xs, ys, min_segment_length, fit_threshold, fit_function, overlap)

    len_xs = length(xs)
    g = SimpleDiGraph(len_xs)
    weightmatrix = zeros(len_xs, len_xs)
    threshold = fit_function == :r2 ? -fit_threshold : fit_threshold

    for j in eachindex(xs)
        jj = overlap ? j : j - 1
        for i in eachindex(xs)
            if i < j && i < jj && is_min_length(xs[i:jj], min_segment_length)
                add_edge!(g, i, j) # i -> j
                _xs = xs[i:jj]
                _ys = ys[i:jj]
                w =
                    fit_function == :r2 ? -rsquared(_xs, _ys, least_squares(_xs, _ys)...) :
                    rmse(_xs, _ys, least_squares(_xs, _ys)...)

                weightmatrix[i, j] = w > threshold ? Inf : w + 1.0 # add a constant offset to make r² all positive
            elseif i == j
                weightmatrix[i, j] = 0.0
            else
                weightmatrix[i, j] = Inf
            end
        end
    end
    g, weightmatrix
end
