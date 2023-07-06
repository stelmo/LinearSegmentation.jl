using LinearSegmentation
using Random
using BenchmarkTools

# settings
min_segment_length = 1.0
max_rmse = 0.10

# generate test data
N = 1000
Nspan = 10
xs = collect(range(0, Nspan * pi, length = N))
ys = sin.(xs)

@benchmark sliding_window(
    $xs,
    $ys;
    min_segment_length = $min_segment_length,
    max_rmse = $max_rmse,
) # 361.015 μs ± 247.885 μs

@benchmark top_down(
    $xs,
    $ys;
    min_segment_length = $min_segment_length,
    max_rmse = $max_rmse,
) # 102.880 ms ± 2.391 ms

@benchmark graph_segmentation(
    $xs,
    $ys;
    min_segment_length = $min_segment_length,
    max_rmse = $max_rmse,
) # 1.894 s ± 22.723 ms
