# -----------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# -----------------------------------------------------------------

module SciTypes

#--------
# TRAITS
#--------

"""
    ScientificType

TODO
"""
abstract type SciType end

"""
    scitype(x) -> SciType
    scitype(T::Type) -> SciType

TODO
"""
function scitype end

"""
    elscitype(itr) -> SciType
    elscitype(T::Type) -> SciType

TODO
"""
function elscitype end

"""
    sciconvert(S::Type{<:SciType}, x)

TODO
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

#----------
# SCITYPES
#----------

abstract type Unknown <: SciType end

abstract type Continuous <: SciType end

abstract type Categorical <: SciType end

abstract type Compositional <: SciType end

#-----------------
# IMPLEMENTATIONS
#-----------------

scitype(::Type) = Unknown
scitype(::Type{Union{}}) = Unknown

scitype(::Type{<:Number}) = Continuous

scitype(::Type{<:Symbol}) = Categorical
scitype(::Type{<:Integer}) = Categorical
scitype(::Type{<:AbstractChar}) = Categorical
scitype(::Type{<:AbstractString}) = Categorical

#------------
# CONVERSION
#------------

sciconvert(::Type{Continuous}, x::Integer) = float(x)

#----------------
# MISSING VALUES
#----------------

scitype(::Type{Missing}) = Unknown
scitype(::Type{Union{T,Missing}}) where {T} = scitype(T)

sciconvert(::Type{<:SciType}, ::Missing) = missing

#-----------
# UTILITIES
#-----------

"""
    coerce(itr, S::Type{<:SciType})

TODO
"""
coerce(itr, ::Type{S}) where {S<:SciType} = map(x -> sciconvert(S, x), itr)

#---------
# EXPORTS
#---------

export scitype, elscitype, coerce

end
