# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module SciTypesCoDaExt

using SciTypes
using CoDa

SciTypes.scitype(::Type{<:Composition}) = SciTypes.Compositional

end
