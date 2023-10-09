abstract type Continuous <: SciType end

abstract type Categorical <: SciType end

#-----------------
# IMPLEMENTATIONS
#-----------------

scitype(::Type{<:Number}) = Continuous

scitype(::Type{<:Symbol}) = Categorical
scitype(::Type{<:Integer}) = Categorical
scitype(::Type{<:AbstractChar}) = Categorical
scitype(::Type{<:AbstractString}) = Categorical

#------------
# CONVERSION
#------------

sciconvert(::Type{Continuous}, x::Integer) = float(x)
