# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module SciTypesUnitfulExt

using SciTypes
using Unitful: AbstractQuantity, Quantity

SciTypes.scitype(::Type{<:AbstractQuantity{T}}) where {T} = scitype(T)
SciTypes.sciconvert(::Type{SciTypes.Continuous}, x::AbstractQuantity{<:Integer}) = float(x)
SciTypes.sciconvert(::Type{SciTypes.Categorical}, x::AbstractQuantity{<:Number}) = convert(Quantity{Int}, x)
SciTypes.sciconvert(::Type{SciTypes.Categorical}, x::AbstractQuantity{<:Integer}) = x

end
