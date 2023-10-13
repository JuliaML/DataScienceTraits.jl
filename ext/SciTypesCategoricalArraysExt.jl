# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module SciTypesCategoricalArraysExt

using SciTypes
using CategoricalArrays

SciTypes.scitype(::Type{<:CategoricalValue}) = SciTypes.Categorical
SciTypes.elscitype(::Type{<:CategoricalArray}) = SciTypes.Categorical

SciTypes.isordered(array::CategoricalArray) = isordered(array)

end
