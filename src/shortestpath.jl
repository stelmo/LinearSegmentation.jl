"""
$(TYPEDSIGNATURES)

Segment `xs` into sections based on the root mean square error using `ys`.
Builds a directed graph where nodes are the x-data points, and the edges are the
root mean square error of fitting a linear model between these nodes. Nodes are
connected only if their minimum length is greater than `min_segment_length` and
the error between them is less than `max_rmse`. Thereafter, the path spanning
the entire dataset with the lowest total error is found using the A-star
algorithm. This more-or-less corresponds to a the dynamic programming approach
used by other segmentation algorithms. 

Sorts data internally as a precomputation step. This is the slowest algorithm,
but *should* return the optimal segmentation.

Returns an array of [`Segment`](@ref)s, and an array of `LinearModel`s from
GLM.jl corresponding to these segments.

# Example
```
segs, fits = shortest_path(xs, ys; min_segment_length=1.2, max_rmse=0.15)
```

See also: [`sliding_window`](@ref), [`top_down`](@ref).
"""
function shortest_path(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    max_rmse = 0.5,
    overlap = true,
)

    segments = Segment[]
    sxs = sortperm(xs) # do this once

    g, w = build_digraph(xs[sxs], ys[sxs], min_segment_length, max_rmse, overlap)

    path_edges = a_star(g, 1, length(xs), w)
    for edge in path_edges
        i = edge.src
        j = edge.dst
        if overlap || j == length(xs)
            jj = j
        else
            jj = j - 1
        end
        push!(segments, Segment(sxs[i:jj]))
    end

    segments, linear_segmentation(segments, xs, ys)
end

"""
$(TYPEDSIGNATURES)

Build a directed graph where each node represents an index, and edges are
segments that link indices. Enumerates all possible segments that are at least
`min_segment_length` long. Weights are assigned by mean squared error of the
linear fit. If rmse is bigger than `max_rmse`, then weight is set to `Inf`.
"""
function build_digraph(xs, ys, min_segment_length, max_rmse, overlap)

    g = SimpleDiGraph(length(xs))
    weightmatrix = zeros(length(xs), length(xs))

    for j = 1:length(xs)
        for i = 1:length(xs)
            jj = overlap ? j : j - 1
            if i < j && i < jj && is_min_length(xs[i:jj], min_segment_length)
                add_edge!(g, i, j) # i -> j
                _xs = xs[i:jj]
                _ys = ys[i:jj]
                r = rmse(_xs, _ys, least_squares(_xs, _ys)...)
                weightmatrix[i, j] = r > max_rmse ? Inf : r
            elseif i == j
                weightmatrix[i, j] = 0.0
            else
                weightmatrix[i, j] = Inf
            end
        end
    end
    g, weightmatrix
end
