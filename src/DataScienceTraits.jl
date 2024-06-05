# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module DataScienceTraits

using Dates: TimeType

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
    Distributional

Scientific type of distributional data (See Distributions.jl)
"""
abstract type Distributional <: SciType end

"""
    Geometrical

Scientific type of geometrical data (See Meshes.jl)
"""
abstract type Geometrical <: SciType end

"""
    Tensorial

Scientific type of tensorial data (e.g. Vector, Matrix)
"""
abstract type Tensorial <: SciType end

"""
    Temporal

Scientific type of temporal data (e.g. Date, Time, DateTime).
"""
abstract type Temporal <: SciType end

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
scitype(::Type{<:Integer}) = Categorical
scitype(::Type{<:AbstractChar}) = Categorical
scitype(::Type{<:AbstractString}) = Categorical
scitype(::Type{<:AbstractArray}) = Tensorial
scitype(::Type{<:TimeType}) = Temporal
scitype(::Type{Union{T,Missing}}) where {T} = scitype(T)

sciconvert(::Type{Continuous}, x::Integer) = float(x)
sciconvert(::Type{Categorical}, x::Symbol) = string(x)
sciconvert(::Type{Categorical}, x::Number) = convert(Int, x)
sciconvert(::Type{Categorical}, x::Integer) = x

#-----------
# UTILITIES
#-----------

"""
    coerce(S::Type{<:SciType}, itr)

Convert the scientific type of elements of the iterable `itr` to `S`, ignoring missing values.
"""
coerce(::Type{S}, itr) where {S<:SciType} = map(x -> ismissing(x) ? missing : sciconvert(S, x), itr)

"""
    isordered(itr)

Checks whether the categorical variables of the iterable `itr` are ordered.
"""
function isordered(itr)
  if !(elscitype(itr) <: Categorical)
    throw(ArgumentError("iterable elements are not categorical"))
  end
  false
end

#---------
# EXPORTS
#---------

export scitype, elscitype

end
