module SciTypesCoDaExt

using SciTypes
using CoDa

SciTypes.scitype(::Type{<:Composition}) = SciTypes.Compositional

end
