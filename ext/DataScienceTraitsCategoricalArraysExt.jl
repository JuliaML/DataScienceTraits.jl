# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module DataScienceTraitsCategoricalArraysExt

using DataScienceTraits
using CategoricalArrays

DataScienceTraits.scitype(::Type{<:CategoricalValue}) = DataScienceTraits.Categorical
DataScienceTraits.elscitype(::Type{<:CategoricalArray}) = DataScienceTraits.Categorical

end
