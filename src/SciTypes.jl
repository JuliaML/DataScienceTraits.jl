# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module SciTypes

"""
    SciType

Parent type of all scientific types.
"""
abstract type SciType end

"""
    Continuous

Scientific type of continuous variables.
"""
abstract type Continuous <: SciType end

"""
    Categorical

Scientific type of categorical (a.k.a. discrete) variables.
"""
abstract type Categorical <: SciType end

"""
    Compositional

Scientific type of compositional data (See CoDa.jl).
"""
abstract type Compositional <: SciType end

"""
    Unknown

Scientific type used as a fallback in the `scitype` trait function.
"""
abstract type Unknown <: SciType end

"""
    scitype(x) -> SciType
    scitype(T::Type) -> SciType

Return the scientific type of object `x` of type `T`.
"""
function scitype end

"""
    elscitype(itr) -> SciType
    elscitype(I::Type) -> SciType

Return the scientific type of the elements of iterator `itr`
of type `I`.
"""
function elscitype end

"""
    sciconvert(S::Type{<:SciType}, x)

Convert the scientific type of object `x` to `S`.
"""
function sciconvert end

#-----------
# FALLBACKS
#-----------

scitype(x) = scitype(typeof(x))

elscitype(itr) = elscitype(typeof(itr))
elscitype(::Type{T}) where {T} = scitype(eltype(T))

function sciconvert(::Type{S}, x::T) where {S<:SciType,T}
  if !(scitype(T) <: S)
    context = :compact => true
    throw(ArgumentError("cannot convert $(repr(x; context)) to $(repr(S; context))"))
  end
  x
end

#-----------------
# IMPLEMENTATIONS
#-----------------

scitype(::Type) = Unknown
scitype(::Type{Union{}}) = Unknown
scitype(::Type{Missing}) = Unknown
scitype(::Type{<:Number}) = Continuous
scitype(::Type{<:Symbol}) = Categorical
scitype(::Type{<:Integer}) = Categorical
scitype(::Type{<:AbstractChar}) = Categorical
scitype(::Type{<:AbstractString}) = Categorical
scitype(::Type{Union{T,Missing}}) where {T} = scitype(T)

sciconvert(::Type{Continuous}, x::Integer) = float(x)
sciconvert(::Type{<:SciType}, ::Missing) = missing

#-----------
# UTILITIES
#-----------

"""
    coerce(itr, S::Type{<:SciType})

Convert the scientific type of iterable `itr` to `S`.
"""
coerce(itr, ::Type{S}) where {S<:SciType} = map(x -> sciconvert(S, x), itr)

#---------
# EXPORTS
#---------

export scitype, elscitype, coerce

end
