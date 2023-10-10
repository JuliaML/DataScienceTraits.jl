module SciTypesDynamicQuantitiesExt

using SciTypes
using DynamicQuantities: AbstractQuantity

SciTypes.scitype(::Type{<:AbstractQuantity{T}}) where {T} = scitype(T)
SciTypes.sciconvert(::Type{SciTypes.Continuous}, x::AbstractQuantity{<:Integer}) = float(x)

end
