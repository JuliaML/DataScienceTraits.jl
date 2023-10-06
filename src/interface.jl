"""
    scitype(x) -> ScientificType
    scitype(::Type) -> ScientificType

TODO
"""
function scitype end

"""
    elscitype(itr) -> ScientificType
    elscitype(::Type) -> ScientificType

TODO
"""
function elscitype end

"""
    ScientificType

TODO
"""
abstract type ScientificType end

#---------
# DEFAULT
#---------

struct Unknown <: ScientificType end

scitype(::Type) = Unknown

#-----------
# FALLBACKS
#-----------

scitype(x) = scitype(typeof(x))

elscitype(itr) = elscitype(typeof(itr))
elscitype(::Type{T}) where {T} = scitype(eltype(T))
