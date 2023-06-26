# """
# $(TYPEDSIGNATURES)

# Segment `xs` based on the root mean square error of the fit.
# """
# function top_down(
#     xs,
#     ys;
#     min_segment_length = heuristic_min_segment_length(xs),
#     max_rmse = 0.5,
#     dx = 1e-6,
# )
#     brk_pnts = Int64[]

#     _top_down!(brk_pnts, xs, ys, 1, length(xs), min_segment_length, max_rmse, dx)

#     segs,
#     [
#         linear_segmentation(xs[s.start_idx:s.end_idx], ys[s.start_idx:s.end_idx]) for
#         s in segs
#     ]
# end

# function _top_down!(brk_pnts, xs, ys, start_idx, stop_idx, min_segment_length, max_rmse, dx)

#     if xs[stop_idx] - xs[start_idx]
#         return nothing
#     end

#     best_rmse, brk_pnt = _find_optimum_break_point(xs, ys, start_idx, stop_idx, min_segment_length, dx)

#     rmse1 = linear_segmentation(xs[start_idx:(brk_pnt-1)], ys[start_idx:(brk_pnt-1)])
#     rmse2 = linear_segmentation(xs[brk_pnt:stop_idx], ys[brk_pnt:stop_idx])

#     if rmse1 <= max_rmse

#     # minimum range length =  2 * min_length so that the ranges can be split in two
#     if best_rmse < max_rmse ||
#        (length(rng1) < min_length * 2 && length(rng2) < min_length * 2)
#         push!(rngs, rng1)
#         push!(rngs, rng2)
#     elseif length(rng1) < min_length * 2
#         push!(rngs, rng1)
#         _top_down!(rngs, first(rng2), last(rng2), min_length, rmse_f; max_rmse)
#     elseif length(rng2) < min_length * 2
#         push!(rngs, rng2)
#         _top_down!(rngs, first(rng1), last(rng1), min_length, rmse_f; max_rmse)
#     else
#         _top_down!(rngs, first(rng1), last(rng1), min_length, rmse_f; max_rmse)
#         _top_down!(rngs, first(rng2), last(rng2), min_length, rmse_f; max_rmse)
#     end

#     nothing
# end

# function _find_optimum_break_point(xs, ys, start1_idx, stop2_idx, min_segment_length, dx)

#     stop1_idx = next_interval(start1_idx, xs; dx)
#     start2_idx = stop1_idx + 1 # must be at least 2 intervals in data
#     best_rmse = Inf
#     brk_pnt = start2_idx
#     while true
#         if is_min_length(xs[start1_idx:stop1_idx], min_segment_length) &&
#            is_min_length(xs[start2_idx:stop2_idx], min_segment_length)

#             s1f = linear_segmentation(xs[start1_idx:stop1_idx], ys[start1_idx:stop1_idx])
#             s2f = linear_segmentation(xs[start2_idx:stop2_idx], ys[start2_idx:stop2_idx])
#             v = (rmse(s1f) + rmse(s2f)) / 2
#             if v < best_rmse
#                 best_rmse = v
#                 brk_pnt = start2_idx
#             end
#         end
#         stop1_idx = next_interval(stop1_idx, xs; dx)
#         isnothing(stop1_idx) && break
#         start2_idx = stop1_idx + 1
#         start2_idx >= stop2_idx && break
#     end

#     best_rmse, brk_pnt
# end
