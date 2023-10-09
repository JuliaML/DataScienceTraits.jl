# SciTypes.jl

[![Build Status](https://github.com/JuliaML/SciTypes.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaML/SciTypes.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaML/SciTypes.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaML/SciTypes.jl)

This package provides an alternative implementation to
[ScientificTypes.jl](https://github.com/JuliaAI/ScientificTypes.jl)
that is lightweight and with a more sensible set of defaults for
data science. See https://github.com/JuliaAI/ScientificTypes.jl/issues/180
for additional context.

## Usage

This package is intended for developers of statistical packages
that need to dispatch different algorithms depending on scientific
types. Without any extra dependency, the author of a package can
load SciTypes.jl and dispatch on the subtypes of `SciType`:

```julia
import SciTypes

reduction(::SciTypes.Continuous) = sum
reduction(::SciTypes.Categorical) = first
```

Extensions are provided for third-party types such as CoDa.jl
and CategoricalArrays.jl in order to facilitate the integration
with existing software stacks.
