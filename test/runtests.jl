using DataScienceTraits
using CategoricalArrays
using Distributions
using Meshes
using CoDa
import DynamicQuantities
import Unitful
using Dates
using Test

const DST = DataScienceTraits

@testset "DataScienceTraits.jl" begin
  @testset "scitype" begin
    # Continuous
    @test scitype(Float32) <: DST.Continuous
    @test scitype(Float64) <: DST.Continuous
    @test scitype(ComplexF32) <: DST.Continuous
    @test scitype(ComplexF64) <: DST.Continuous
    @test scitype(1.0f0) <: DST.Continuous
    @test scitype(1.0) <: DST.Continuous
    @test scitype(1.0f0 + 2im) <: DST.Continuous
    @test scitype(1.0 + 2im) <: DST.Continuous

    # Categorical
    @test scitype(Int) <: DST.Categorical
    @test scitype(Char) <: DST.Categorical
    @test scitype(String) <: DST.Categorical
    @test scitype(1) <: DST.Categorical
    @test scitype('a') <: DST.Categorical
    @test scitype("a") <: DST.Categorical

    # Unknown
    @test scitype(Nothing) <: DST.Unknown
    @test scitype(Union{}) <: DST.Unknown
    @test scitype(nothing) <: DST.Unknown
  end

  @testset "elscitype" begin
    # Continuous
    @test elscitype(Vector{Float32}) <: DST.Continuous
    @test elscitype(Vector{Float64}) <: DST.Continuous
    @test elscitype(NTuple{3,ComplexF32}) <: DST.Continuous
    @test elscitype(NTuple{3,ComplexF64}) <: DST.Continuous
    @test elscitype((1.0f0, 2.0f0, 3.0f0)) <: DST.Continuous
    @test elscitype(1:0.1:3) <: DST.Continuous
    @test elscitype([1.0f0, 2.0f0, 3.0f0] .+ 2im) <: DST.Continuous
    @test elscitype([1.0, 2.0, 3.0] .+ 2im) <: DST.Continuous

    # Categorical
    @test elscitype(Vector{Int}) <: DST.Categorical
    @test elscitype(NTuple{3,Char}) <: DST.Categorical
    @test elscitype(NTuple{3,String}) <: DST.Categorical
    @test elscitype((1, 2, 3)) <: DST.Categorical
    @test elscitype('a':'c') <: DST.Categorical
    @test elscitype(["a", "b", "c"]) <: DST.Categorical

    # Unknown
    @test elscitype(Vector{Nothing}) <: DST.Unknown
    @test elscitype(Tuple{}) <: DST.Unknown
    @test elscitype(fill(nothing, 3)) <: DST.Unknown
    @test elscitype(()) <: DST.Unknown
  end

  @testset "sciconvert" begin
    # fallback: Continuous
    for x in (1.0f0, 1.0, 1.0f0 + 2im, 1.0 + 2im)
      @test DST.sciconvert(DST.Continuous, x) === x
      @test scitype(DST.sciconvert(DST.Continuous, x)) <: DST.Continuous
    end

    # fallback: Categorical
    for x in ('a', "a")
      @test DST.sciconvert(DST.Categorical, x) === x
      @test scitype(DST.sciconvert(DST.Categorical, x)) <: DST.Categorical
    end

    # fallback: Unknown
    @test DST.sciconvert(DST.Unknown, :a) === :a
    @test scitype(DST.sciconvert(DST.Unknown, :a)) <: DST.Unknown
    @test DST.sciconvert(DST.Unknown, nothing) === nothing
    @test scitype(DST.sciconvert(DST.Unknown, nothing)) <: DST.Unknown

    # Interger to Continuous
    @test DST.sciconvert(DST.Continuous, 1) === 1.0
    @test scitype(DST.sciconvert(DST.Continuous, 1)) <: DST.Continuous

    # Symbol to Categorical
    @test DST.sciconvert(DST.Categorical, :a) === "a"
    @test scitype(DST.sciconvert(DST.Categorical, :a)) <: DST.Categorical

    # Number to Categorical
    @test DST.sciconvert(DST.Categorical, 1.0) === 1
    @test scitype(DST.sciconvert(DST.Categorical, 1.0)) <: DST.Categorical

    # no conversion: Integer to Categorical
    @test DST.sciconvert(DST.Categorical, Int32(1)) === Int32(1)
    @test scitype(DST.sciconvert(DST.Categorical, Int32(1))) <: DST.Categorical

    # throws
    @test_throws ArgumentError DST.sciconvert(DST.Continuous, nothing)
  end

  @testset "coerce" begin
    @test DST.coerce(DST.Continuous, [1, 2, 3]) == [1.0, 2.0, 3.0]
    @test elscitype(DST.coerce(DST.Continuous, [1, 2, 3])) <: DST.Continuous
    @test DST.coerce(DST.Continuous, (1, 2, 3)) == (1.0, 2.0, 3.0)
    @test elscitype(DST.coerce(DST.Continuous, (1, 2, 3))) <: DST.Continuous
    @test DST.coerce(DST.Categorical, [:a, :b, :c]) == ["a", "b", "c"]
    @test elscitype(DST.coerce(DST.Categorical, [:a, :b, :c])) <: DST.Categorical
    @test DST.coerce(DST.Categorical, (:a, :b, :c)) == ("a", "b", "c")
    @test elscitype(DST.coerce(DST.Categorical, (:a, :b, :c))) <: DST.Categorical
    @test DST.coerce(DST.Categorical, [1.0, 2.0, 3.0]) == [1, 2, 3]
    @test elscitype(DST.coerce(DST.Categorical, [1.0, 2.0, 3.0])) <: DST.Categorical
    @test DST.coerce(DST.Categorical, (1.0, 2.0, 3.0)) == (1, 2, 3)
    @test elscitype(DST.coerce(DST.Categorical, (1.0, 2.0, 3.0))) <: DST.Categorical
  end

  @testset "isordered" begin
    @test !DST.isordered([1, 2, 3])
    @test !DST.isordered(['a', 'b', 'c'])
    @test !DST.isordered(("a", "b", "c"))

    # throws
    @test_throws ArgumentError DST.isordered([1.0, 2.0, 3.0])
  end

  @testset "missing values" begin
    @test scitype(Missing) <: DST.Unknown
    @test scitype(Union{Float64,Missing}) <: DST.Continuous
    @test scitype(Union{Int,Missing}) <: DST.Categorical
    @test elscitype(fill(missing, 3)) <: DST.Unknown
    @test elscitype([1.0, missing, 3.0]) <: DST.Continuous
    @test elscitype([1, missing, 3]) <: DST.Categorical
    @test isequal(DST.coerce(DST.Continuous, [1, missing, 3]), [1.0, missing, 3.0])
    @test elscitype(DST.coerce(DST.Continuous, [1, missing, 3])) <: DST.Continuous
    @test isequal(DST.coerce(DST.Categorical, [:a, missing, :c]), ["a", missing, "c"])
    @test elscitype(DST.coerce(DST.Categorical, [:a, missing, :c])) <: DST.Categorical
    @test isequal(DST.coerce(DST.Categorical, [1.0, missing, 3.0]), [1, missing, 3])
    @test elscitype(DST.coerce(DST.Categorical, [1.0, missing, 3.0])) <: DST.Categorical
  end

  @testset "CoDa" begin
    c1 = Composition(a=0.2, b=0.8)
    c2 = Composition(a=0.5, b=0.5)
    @test scitype(Composition{2,(:a, :b)}) <: DST.Compositional
    @test scitype(c1) <: DST.Compositional
    @test elscitype(Vector{Composition{2,(:a, :b)}}) <: DST.Compositional
    @test elscitype([c1, c2]) <: DST.Compositional
    @test elscitype([c1, missing, c2]) <: DST.Compositional
  end

  @testset "Unitful" begin
    u = Unitful.u"m"
    q1 = 1 * u
    q2 = 1.0 * u
    Q1 = typeof(q1)
    Q2 = typeof(q2)
    @test scitype(Q1) <: DST.Categorical
    @test scitype(Q2) <: DST.Continuous
    @test scitype(q1) <: DST.Categorical
    @test scitype(q2) <: DST.Continuous
    @test elscitype(Vector{Q1}) <: DST.Categorical
    @test elscitype(Vector{Q2}) <: DST.Continuous
    @test elscitype([1, 2, 3] * u) <: DST.Categorical
    @test elscitype([1.0, 2.0, 3.0] * u) <: DST.Continuous
    @test elscitype([1, missing, 3] * u) <: DST.Categorical
    @test elscitype([1.0, missing, 3.0] * u) <: DST.Continuous
    # Quantity{Interger} to Continuous
    @test DST.sciconvert(DST.Continuous, 1 * u) === 1.0 * u
    @test scitype(DST.sciconvert(DST.Continuous, 1 * u)) <: DST.Continuous
    # Quantity{Number} to Categorical
    @test DST.sciconvert(DST.Categorical, 1.0 * u) === 1 * u
    @test scitype(DST.sciconvert(DST.Categorical, 1.0 * u)) <: DST.Categorical
    # no conversion: Quantity{Interger} to Categorical
    @test DST.sciconvert(DST.Categorical, Int32(1) * u) === Int32(1) * u
    @test scitype(DST.sciconvert(DST.Categorical, Int32(1) * u)) <: DST.Categorical
    # coercion
    @test DST.coerce(DST.Continuous, [1, 2, 3] * u) == [1.0, 2.0, 3.0] * u
    @test elscitype(DST.coerce(DST.Continuous, [1, 2, 3] * u)) <: DST.Continuous
    @test isequal(DST.coerce(DST.Continuous, [1, missing, 3] * u), [1.0, missing, 3.0] * u)
    @test elscitype(DST.coerce(DST.Continuous, [1, missing, 3] * u)) <: DST.Continuous
    @test DST.coerce(DST.Categorical, [1.0, 2.0, 3.0] * u) == [1, 2, 3] * u
    @test elscitype(DST.coerce(DST.Categorical, [1.0, 2.0, 3.0] * u)) <: DST.Categorical
    @test isequal(DST.coerce(DST.Categorical, [1.0, missing, 3.0] * u), [1, missing, 3] * u)
    @test elscitype(DST.coerce(DST.Categorical, [1.0, missing, 3.0] * u)) <: DST.Categorical
  end

  @testset "DynamicQuantities" begin
    uf = DynamicQuantities.u"m"
    ui = DynamicQuantities.Quantity{Int}(uf)
    q1 = 1 * ui
    q2 = 1.0 * uf
    Q1 = typeof(q1)
    Q2 = typeof(q2)
    @test scitype(Q1) <: DST.Categorical
    @test scitype(Q2) <: DST.Continuous
    @test scitype(q1) <: DST.Categorical
    @test scitype(q2) <: DST.Continuous
    @test elscitype(Vector{Q1}) <: DST.Categorical
    @test elscitype(Vector{Q2}) <: DST.Continuous
    @test elscitype([1, 2, 3] .* ui) <: DST.Categorical
    @test elscitype([1.0, 2.0, 3.0] .* uf) <: DST.Continuous
    @test elscitype([1 * ui, missing, 3 * ui]) <: DST.Categorical
    @test elscitype([1.0 * uf, missing, 3.0 * uf]) <: DST.Continuous
    # Quantity{Interger} to Continuous
    @test DST.sciconvert(DST.Continuous, 1 * ui) === 1.0 * uf
    @test scitype(DST.sciconvert(DST.Continuous, 1 * ui)) <: DST.Continuous
    # Quantity{Number} to Categorical
    @test DST.sciconvert(DST.Categorical, 1.0 * uf) === 1 * ui
    @test scitype(DST.sciconvert(DST.Categorical, 1.0 * uf)) <: DST.Categorical
    # no conversion: Quantity{Interger} to Categorical
    q3 = DynamicQuantities.Quantity{Int32}(q1)
    @test DST.sciconvert(DST.Categorical, q3) === q3
    @test scitype(DST.sciconvert(DST.Categorical, q3)) <: DST.Categorical
    # coercion
    @test DST.coerce(DST.Continuous, [1, 2, 3] .* ui) == [1.0, 2.0, 3.0] .* uf
    @test elscitype(DST.coerce(DST.Continuous, [1, 2, 3] .* ui)) <: DST.Continuous
    @test isequal(DST.coerce(DST.Continuous, [1 * ui, missing, 3 * ui]), [1.0 * uf, missing, 3.0 * uf])
    @test elscitype(DST.coerce(DST.Continuous, [1 * ui, missing, 3 * ui])) <: DST.Continuous
    @test DST.coerce(DST.Categorical, [1.0, 2.0, 3.0] .* uf) == [1, 2, 3] .* ui
    @test elscitype(DST.coerce(DST.Categorical, [1.0, 2.0, 3.0] .* uf)) <: DST.Categorical
    @test isequal(DST.coerce(DST.Categorical, [1.0 * uf, missing, 3.0 * uf]), [1 * ui, missing, 3 * ui])
    @test elscitype(DST.coerce(DST.Categorical, [1.0 * uf, missing, 3.0 * uf])) <: DST.Categorical
  end

  @testset "CategoricalArrays" begin
    carr = categorical([1, 2, 3])
    cval = first(carr)
    CV = typeof(cval)
    CA = typeof(carr)
    @test scitype(CV) <: DST.Categorical
    @test scitype(cval) <: DST.Categorical
    @test elscitype(CA) <: DST.Categorical
    @test elscitype(carr) <: DST.Categorical
    @test elscitype(categorical([1, missing, 3])) <: DST.Categorical
    @test !DST.isordered(carr)
    carr = categorical([1, 3, 2], ordered=true)
    @test DST.isordered(carr)
  end

  @testset "Distributions" begin
    @test scitype(Normal()) <: DST.Distributional
    @test scitype(Exponential()) <: DST.Distributional
  end

  @testset "Meshes" begin
    @test scitype(rand(Point2)) <: DST.Geometrical
    @test scitype(rand(Triangle{2,Float64})) <: DST.Geometrical
    @test scitype(rand(Triangle{2,Float64})) <: DST.Geometrical
  end
end
