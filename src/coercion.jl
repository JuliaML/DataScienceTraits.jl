"""
    coerce(itr, S::Type{<:SciType})

TODO
"""
coerce(itr, ::Type{S}) where {S<:SciType} = map(x -> sciconvert(S, x), itr)
