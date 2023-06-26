"""
$(TYPEDSIGNATURES)

Only return fits to segments longer than `min_segment_length`. Break segments
when root mean squared error of the linear fitted residuals is greater than
`max_rmse`. 
    
Use `dx` to indicate how big the expected steps are between `xs`, e.g. if `xs =
[1, 2, 3]` then `dx = 1` is okay, whereas if `xs = [0, 0.5, 1.0]` then `dx =
0.5` would work. This is particularly important if there are multiple
observations at slightly different times that should count as "one", e.g. `xs =
[0, 0.013, 0.012, 1.01, 0.99, 1.03]`, here `dx` should be something larger than
the noise between measurements, e.g. `dx = 0.2`. Defaulting to a small `dx`
means every measurement should count individually.  

Returns an array of [`Segment`](@ref)s and an array of `LinearModel`s from
GLM.jl corresponding to these segments.
"""
function sliding_window(
    xs,
    ys;
    min_segment_length = heuristic_min_segment_length(xs),
    max_rmse = 0.5,
    dx = 1e-6,
)   
    sxs = sortperm(xs)

    segments = Segment[]
    lms = LinearModel[]
    
    for i in sxs[2:end]

    end

    start_idx = 1
    while true
        current_idx = next_interval(start_idx, xs; dx)
        isnothing(current_idx) && break

        isdone = false
        while true

            if !isdone && is_min_length(xs[start_idx:current_idx], min_segment_length)
                next_idx = next_interval(current_idx, xs; dx)
                if isnothing(next_idx)
                    isdone = true
                else
                    _xs = xs[start_idx:next_idx]
                    _ys = ys[start_idx:next_idx]
                    lmfit = linear_segmentation(_xs, _ys)
                    if rmse(lmfit) >= max_rmse
                        isdone = true
                    end
                end
            end

            if isdone
                push!(segments, Segment(start_idx, current_idx))
                push!(
                    lms,
                    linear_segmentation(
                        xs[start_idx:current_idx],
                        ys[start_idx:current_idx],
                    ),
                )
                start_idx = current_idx + 1
                break
            end

            current_idx = next_interval(current_idx, xs; dx)
            if isnothing(current_idx)
                current_idx = length(xs)
                isdone = true
            end
        end

    end

    segments, lms
end
