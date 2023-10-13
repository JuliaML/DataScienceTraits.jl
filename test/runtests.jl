using SciTypes
using CategoricalArrays
import DynamicQuantities
import Unitful
using CoDa
using Test

@testset "SciTypes.jl" begin
  @testset "scitype" begin
    # Continuous
    @test scitype(Float32) <: SciTypes.Continuous
    @test scitype(Float64) <: SciTypes.Continuous
    @test scitype(ComplexF32) <: SciTypes.Continuous
    @test scitype(ComplexF64) <: SciTypes.Continuous
    @test scitype(1.0f0) <: SciTypes.Continuous
    @test scitype(1.0) <: SciTypes.Continuous
    @test scitype(1.0f0 + 2im) <: SciTypes.Continuous
    @test scitype(1.0 + 2im) <: SciTypes.Continuous

    # Categorical
    @test scitype(Int) <: SciTypes.Categorical
    @test scitype(Char) <: SciTypes.Categorical
    @test scitype(String) <: SciTypes.Categorical
    @test scitype(1) <: SciTypes.Categorical
    @test scitype('a') <: SciTypes.Categorical
    @test scitype("a") <: SciTypes.Categorical

    # Unknown
    @test scitype(Nothing) <: SciTypes.Unknown
    @test scitype(Union{}) <: SciTypes.Unknown
    @test scitype(nothing) <: SciTypes.Unknown
  end

  @testset "elscitype" begin
    # Continuous
    @test elscitype(Vector{Float32}) <: SciTypes.Continuous
    @test elscitype(Vector{Float64}) <: SciTypes.Continuous
    @test elscitype(NTuple{3,ComplexF32}) <: SciTypes.Continuous
    @test elscitype(NTuple{3,ComplexF64}) <: SciTypes.Continuous
    @test elscitype((1.0f0, 2.0f0, 3.0f0)) <: SciTypes.Continuous
    @test elscitype(1:0.1:3) <: SciTypes.Continuous
    @test elscitype([1.0f0, 2.0f0, 3.0f0] .+ 2im) <: SciTypes.Continuous
    @test elscitype([1.0, 2.0, 3.0] .+ 2im) <: SciTypes.Continuous

    # Categorical
    @test elscitype(Vector{Int}) <: SciTypes.Categorical
    @test elscitype(NTuple{3,Char}) <: SciTypes.Categorical
    @test elscitype(NTuple{3,String}) <: SciTypes.Categorical
    @test elscitype((1, 2, 3)) <: SciTypes.Categorical
    @test elscitype('a':'c') <: SciTypes.Categorical
    @test elscitype(["a", "b", "c"]) <: SciTypes.Categorical

    # Unknown
    @test elscitype(Vector{Nothing}) <: SciTypes.Unknown
    @test elscitype(Tuple{}) <: SciTypes.Unknown
    @test elscitype(fill(nothing, 3)) <: SciTypes.Unknown
    @test elscitype(()) <: SciTypes.Unknown
  end

  @testset "sciconvert" begin
    # fallback: Continuous
    for x in (1.0f0, 1.0, 1.0f0 + 2im, 1.0 + 2im)
      @test SciTypes.sciconvert(SciTypes.Continuous, x) === x
      @test scitype(SciTypes.sciconvert(SciTypes.Continuous, x)) <: SciTypes.Continuous
    end

    # fallback: Categorical
    for x in ('a', "a")
      @test SciTypes.sciconvert(SciTypes.Categorical, x) === x
      @test scitype(SciTypes.sciconvert(SciTypes.Categorical, x)) <: SciTypes.Categorical
    end

    # fallback: Unknown
    @test SciTypes.sciconvert(SciTypes.Unknown, nothing) === nothing
    @test scitype(SciTypes.sciconvert(SciTypes.Unknown, nothing)) <: SciTypes.Unknown

    # Interger to Continuous
    @test SciTypes.sciconvert(SciTypes.Continuous, 1) === 1.0
    @test scitype(SciTypes.sciconvert(SciTypes.Continuous, 1)) <: SciTypes.Continuous

    # Number to Categorical
    @test SciTypes.sciconvert(SciTypes.Categorical, 1.0) === 1
    @test scitype(SciTypes.sciconvert(SciTypes.Categorical, 1.0)) <: SciTypes.Categorical

    # no conversion: Integer to Categorical
    @test SciTypes.sciconvert(SciTypes.Categorical, Int32(1)) === Int32(1)
    @test scitype(SciTypes.sciconvert(SciTypes.Categorical, Int32(1))) <: SciTypes.Categorical

    # throws
    @test_throws ArgumentError SciTypes.sciconvert(SciTypes.Continuous, nothing)
  end

  @testset "coerce" begin
    @test SciTypes.coerce(SciTypes.Continuous, [1, 2, 3]) == [1.0, 2.0, 3.0]
    @test elscitype(SciTypes.coerce(SciTypes.Continuous, [1, 2, 3])) <: SciTypes.Continuous
    @test SciTypes.coerce(SciTypes.Continuous, (1, 2, 3)) == (1.0, 2.0, 3.0)
    @test elscitype(SciTypes.coerce(SciTypes.Continuous, (1, 2, 3))) <: SciTypes.Continuous
    @test SciTypes.coerce(SciTypes.Categorical, [1.0, 2.0, 3.0]) == [1, 2, 3]
    @test elscitype(SciTypes.coerce(SciTypes.Categorical, [1.0, 2.0, 3.0])) <: SciTypes.Categorical
    @test SciTypes.coerce(SciTypes.Categorical, (1.0, 2.0, 3.0)) == (1, 2, 3)
    @test elscitype(SciTypes.coerce(SciTypes.Categorical, (1.0, 2.0, 3.0))) <: SciTypes.Categorical
  end

  @testset "isordered" begin
    @test !SciTypes.isordered([1, 2, 3])
    @test !SciTypes.isordered(['a', 'b', 'c'])
    @test !SciTypes.isordered(("a", "b", "c"))

    # throws
    @test_throws ArgumentError SciTypes.isordered([1.0, 2.0, 3.0])
  end

  @testset "missing values" begin
    @test scitype(Missing) <: SciTypes.Unknown
    @test scitype(Union{Float64,Missing}) <: SciTypes.Continuous
    @test scitype(Union{Int,Missing}) <: SciTypes.Categorical
    @test elscitype(fill(missing, 3)) <: SciTypes.Unknown
    @test elscitype([1.0, missing, 3.0]) <: SciTypes.Continuous
    @test elscitype([1, missing, 3]) <: SciTypes.Categorical
    @test isequal(SciTypes.coerce(SciTypes.Continuous, [1, missing, 3]), [1.0, missing, 3.0])
    @test elscitype(SciTypes.coerce(SciTypes.Continuous, [1, missing, 3])) <: SciTypes.Continuous
    @test isequal(SciTypes.coerce(SciTypes.Categorical, [1.0, missing, 3.0]), [1, missing, 3])
    @test elscitype(SciTypes.coerce(SciTypes.Categorical, [1.0, missing, 3.0])) <: SciTypes.Categorical
  end

  @testset "CoDa" begin
    c1 = Composition(a=0.2, b=0.8)
    c2 = Composition(a=0.5, b=0.5)
    @test scitype(Composition{2,(:a, :b)}) <: SciTypes.Compositional
    @test scitype(c1) <: SciTypes.Compositional
    @test elscitype(Vector{Composition{2,(:a, :b)}}) <: SciTypes.Compositional
    @test elscitype([c1, c2]) <: SciTypes.Compositional
    @test elscitype([c1, missing, c2]) <: SciTypes.Compositional
  end

  @testset "Unitful" begin
    u = Unitful.u"m"
    q1 = 1 * u
    q2 = 1.0 * u
    Q1 = typeof(q1)
    Q2 = typeof(q2)
    @test scitype(Q1) <: SciTypes.Categorical
    @test scitype(Q2) <: SciTypes.Continuous
    @test scitype(q1) <: SciTypes.Categorical
    @test scitype(q2) <: SciTypes.Continuous
    @test elscitype(Vector{Q1}) <: SciTypes.Categorical
    @test elscitype(Vector{Q2}) <: SciTypes.Continuous
    @test elscitype([1, 2, 3] * u) <: SciTypes.Categorical
    @test elscitype([1.0, 2.0, 3.0] * u) <: SciTypes.Continuous
    @test elscitype([1, missing, 3] * u) <: SciTypes.Categorical
    @test elscitype([1.0, missing, 3.0] * u) <: SciTypes.Continuous
    # Quantity{Interger} to Continuous
    @test SciTypes.sciconvert(SciTypes.Continuous, 1 * u) === 1.0 * u
    @test scitype(SciTypes.sciconvert(SciTypes.Continuous, 1 * u)) <: SciTypes.Continuous
    # Quantity{Number} to Categorical
    @test SciTypes.sciconvert(SciTypes.Categorical, 1.0 * u) === 1 * u
    @test scitype(SciTypes.sciconvert(SciTypes.Categorical, 1.0 * u)) <: SciTypes.Categorical
    # no conversion: Quantity{Interger} to Categorical
    @test SciTypes.sciconvert(SciTypes.Categorical, Int32(1) * u) === Int32(1) * u
    @test scitype(SciTypes.sciconvert(SciTypes.Categorical, Int32(1) * u)) <: SciTypes.Categorical
    # coercion
    @test SciTypes.coerce(SciTypes.Continuous, [1, 2, 3] * u) == [1.0, 2.0, 3.0] * u
    @test elscitype(SciTypes.coerce(SciTypes.Continuous, [1, 2, 3] * u)) <: SciTypes.Continuous
    @test isequal(SciTypes.coerce(SciTypes.Continuous, [1, missing, 3] * u), [1.0, missing, 3.0] * u)
    @test elscitype(SciTypes.coerce(SciTypes.Continuous, [1, missing, 3] * u)) <: SciTypes.Continuous
    @test SciTypes.coerce(SciTypes.Categorical, [1.0, 2.0, 3.0] * u) == [1, 2, 3] * u
    @test elscitype(SciTypes.coerce(SciTypes.Categorical, [1.0, 2.0, 3.0] * u)) <: SciTypes.Categorical
    @test isequal(SciTypes.coerce(SciTypes.Categorical, [1.0, missing, 3.0] * u), [1, missing, 3] * u)
    @test elscitype(SciTypes.coerce(SciTypes.Categorical, [1.0, missing, 3.0] * u)) <: SciTypes.Categorical
  end

  @testset "DynamicQuantities" begin
    uf = DynamicQuantities.u"m"
    ui = DynamicQuantities.Quantity{Int}(uf)
    q1 = 1 * ui
    q2 = 1.0 * uf
    Q1 = typeof(q1)
    Q2 = typeof(q2)
    @test scitype(Q1) <: SciTypes.Categorical
    @test scitype(Q2) <: SciTypes.Continuous
    @test scitype(q1) <: SciTypes.Categorical
    @test scitype(q2) <: SciTypes.Continuous
    @test elscitype(Vector{Q1}) <: SciTypes.Categorical
    @test elscitype(Vector{Q2}) <: SciTypes.Continuous
    @test elscitype([1, 2, 3] .* ui) <: SciTypes.Categorical
    @test elscitype([1.0, 2.0, 3.0] .* uf) <: SciTypes.Continuous
    @test elscitype([1 * ui, missing, 3 * ui]) <: SciTypes.Categorical
    @test elscitype([1.0 * uf, missing, 3.0 * uf]) <: SciTypes.Continuous
    # Quantity{Interger} to Continuous
    @test SciTypes.sciconvert(SciTypes.Continuous, 1 * ui) === 1.0 * uf
    @test scitype(SciTypes.sciconvert(SciTypes.Continuous, 1 * ui)) <: SciTypes.Continuous
    # Quantity{Number} to Categorical
    @test SciTypes.sciconvert(SciTypes.Categorical, 1.0 * uf) === 1 * ui
    @test scitype(SciTypes.sciconvert(SciTypes.Categorical, 1.0 * uf)) <: SciTypes.Categorical
    # no conversion: Quantity{Interger} to Categorical
    q3 = DynamicQuantities.Quantity{Int32}(q1)
    @test SciTypes.sciconvert(SciTypes.Categorical, q3) === q3
    @test scitype(SciTypes.sciconvert(SciTypes.Categorical, q3)) <: SciTypes.Categorical
    # coercion
    @test SciTypes.coerce(SciTypes.Continuous, [1, 2, 3] .* ui) == [1.0, 2.0, 3.0] .* uf
    @test elscitype(SciTypes.coerce(SciTypes.Continuous, [1, 2, 3] .* ui)) <: SciTypes.Continuous
    @test isequal(SciTypes.coerce(SciTypes.Continuous, [1 * ui, missing, 3 * ui]), [1.0 * uf, missing, 3.0 * uf])
    @test elscitype(SciTypes.coerce(SciTypes.Continuous, [1 * ui, missing, 3 * ui])) <: SciTypes.Continuous
    @test SciTypes.coerce(SciTypes.Categorical, [1.0, 2.0, 3.0] .* uf) == [1, 2, 3] .* ui
    @test elscitype(SciTypes.coerce(SciTypes.Categorical, [1.0, 2.0, 3.0] .* uf)) <: SciTypes.Categorical
    @test isequal(SciTypes.coerce(SciTypes.Categorical, [1.0 * uf, missing, 3.0 * uf]), [1 * ui, missing, 3 * ui])
    @test elscitype(SciTypes.coerce(SciTypes.Categorical, [1.0 * uf, missing, 3.0 * uf])) <: SciTypes.Categorical
  end

  @testset "CategoricalArrays" begin
    carr = categorical([1, 2, 3])
    cval = first(carr)
    CV = typeof(cval)
    CA = typeof(carr)
    @test scitype(CV) <: SciTypes.Categorical
    @test scitype(cval) <: SciTypes.Categorical
    @test elscitype(CA) <: SciTypes.Categorical
    @test elscitype(carr) <: SciTypes.Categorical
    @test elscitype(categorical([1, missing, 3])) <: SciTypes.Categorical
    @test !SciTypes.isordered(carr)
    carr = categorical([1, 3, 2], ordered=true)
    @test SciTypes.isordered(carr)
  end
end
