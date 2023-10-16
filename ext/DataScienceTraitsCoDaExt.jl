# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module DataScienceTraitsCoDaExt

using DataScienceTraits
using CoDa

DataScienceTraits.scitype(::Type{<:Composition}) = DataScienceTraits.Compositional

end
