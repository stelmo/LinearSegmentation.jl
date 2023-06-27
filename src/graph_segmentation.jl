function graph_segmentation(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    max_rmse = 0.5,
)

    segments = Segment[]
    sxs = sortperm(xs) # do this once

    g, w = build_digraph(xs[sxs], ys[sxs], min_segment_length, max_rmse)

    path_edges = a_star(g, 1, length(xs), w)
    for edge in path_edges
        push!(segments, Segment(sxs[edge.src:edge.dst]))
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
function build_digraph(xs, ys, min_segment_length, max_rmse)

    g = SimpleDiGraph(length(xs))
    weightmatrix = zeros(length(xs), length(xs))

    for j = 1:length(xs)
        for i = 1:length(xs)

            if i < j && is_min_length(xs[i:j], min_segment_length)
                add_edge!(g, i, j) # i -> j
                r = rmse(xs[i:j], ys[i:j], least_squares(xs[i:j], ys[i:j])...)
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
