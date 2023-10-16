# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module DataScienceTraitsDynamicQuantitiesExt

using DataScienceTraits
using DynamicQuantities: AbstractQuantity, Quantity

DataScienceTraits.scitype(::Type{<:AbstractQuantity{T}}) where {T} = scitype(T)
DataScienceTraits.sciconvert(::Type{DataScienceTraits.Continuous}, x::AbstractQuantity{<:Integer}) = float(x)
DataScienceTraits.sciconvert(::Type{DataScienceTraits.Categorical}, x::AbstractQuantity{<:Number}) = convert(Quantity{Int}, x)
DataScienceTraits.sciconvert(::Type{DataScienceTraits.Categorical}, x::AbstractQuantity{<:Integer}) = x

end
