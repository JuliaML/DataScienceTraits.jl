using SciTypes
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
    @test scitype(Symbol) <: SciTypes.Categorical
    @test scitype(Int) <: SciTypes.Categorical
    @test scitype(Char) <: SciTypes.Categorical
    @test scitype(String) <: SciTypes.Categorical
    @test scitype(:a) <: SciTypes.Categorical
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
    @test elscitype(Vector{Symbol}) <: SciTypes.Categorical
    @test elscitype(Vector{Int}) <: SciTypes.Categorical
    @test elscitype(NTuple{3,Char}) <: SciTypes.Categorical
    @test elscitype(NTuple{3,String}) <: SciTypes.Categorical
    @test elscitype((:a, :b, :c)) <: SciTypes.Categorical
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
    for x in (:a, 1, 'a', "a")
      @test SciTypes.sciconvert(SciTypes.Categorical, x) === x
      @test scitype(SciTypes.sciconvert(SciTypes.Categorical, x)) <: SciTypes.Categorical
    end

    # fallback: Unknown
    @test SciTypes.sciconvert(SciTypes.Unknown, nothing) === nothing
    @test scitype(SciTypes.sciconvert(SciTypes.Unknown, nothing)) <: SciTypes.Unknown

    # interger to Continuous
    @test SciTypes.sciconvert(SciTypes.Continuous, 1) == 1.0
    @test scitype(SciTypes.sciconvert(SciTypes.Continuous, 1)) <: SciTypes.Continuous

    # throws
    @test_throws ArgumentError SciTypes.sciconvert(SciTypes.Continuous, nothing)
  end

  @testset "coerce" begin
    @test coerce([1, 2, 3], SciTypes.Continuous) == [1.0, 2.0, 3.0]
    @test elscitype(coerce([1, 2, 3], SciTypes.Continuous)) <: SciTypes.Continuous
    @test coerce((1, 2, 3), SciTypes.Continuous) == (1.0, 2.0, 3.0)
    @test elscitype(coerce((1, 2, 3), SciTypes.Continuous)) <: SciTypes.Continuous
  end

  @testset "missing values" begin
    @test scitype(Missing) <: SciTypes.Unknown
    @test scitype(Union{Float64,Missing}) <: SciTypes.Continuous
    @test scitype(Union{Int,Missing}) <: SciTypes.Categorical
    @test elscitype(fill(missing, 3)) <: SciTypes.Unknown
    @test elscitype([1.0, missing, 3.0]) <: SciTypes.Continuous
    @test elscitype([1, missing, 3]) <: SciTypes.Categorical
    @test isequal(coerce([1, missing, 3], SciTypes.Continuous), [1.0, missing, 3.0])
  end
end
