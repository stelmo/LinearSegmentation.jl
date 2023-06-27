# LinearSegmentation

[repostatus-url]: https://www.repostatus.org/#active
[repostatus-img]: https://www.repostatus.org/badges/latest/active.svg

[![Build Status](https://github.com/stelmo/LinearSegmentation.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/stelmo/LinearSegmentation.jl/actions/workflows/CI.yml?query=branch%3Amaster) [![repostatus-img]][repostatus-url] [![Escher Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/LinearSegmentation)](https://pkgs.genieframework.com?packages=LinearSegmentation)


# Generate some data
```julia
N = 100
xs = collect(range(0, 3 * pi, length = N)) .+ 0.1 .* randn(N)
ys = sin.(xs) .+ 0.1 .* randn(N)
```
![Raw data to be segmented](imgs/data.png)

# Sliding window

# Top down

# Graph segmentation

# Other useful resources
https://cran.r-project.org/web/packages/dpseg/vignettes/dpseg.html#appi