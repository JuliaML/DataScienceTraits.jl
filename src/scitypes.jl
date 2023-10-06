abstract type Infinity <: ScientificType end

struct Count <: Infinity end

scitype(::Type{<:Integer}) = Count
scitype(::Type{<:Rational}) = Count

struct Continuous <: Infinity end

scitype(::Type{<:Real}) = Continuous
scitype(::Type{<:Complex{<:Real}}) = Continuous

struct Text <: ScientificType end

scitype(::Type{<:AbstractChar}) = Text
scitype(::Type{<:AbstractString}) = Text
