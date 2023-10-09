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

"""
    ScientificType

TODO
"""
abstract type SciType end

#---------
# DEFAULT
#---------

struct Unknown <: SciType end

scitype(::Type) = Unknown
scitype(::Type{Union{}}) = Unknown

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

#----------------
# MISSING VALUES
#----------------

scitype(::Type{Missing}) = Unknown
scitype(::Type{Union{T,Missing}}) where {T} = scitype(T)

sciconvert(::Type{<:SciType}, ::Missing) = missing
