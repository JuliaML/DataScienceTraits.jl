using SciTypes
using Test

@testset "SciTypes.jl" begin
  @testset "scitype" begin
    # Continuous
    @test scitype(Float32) <: SciTypes.Continuous
    @test scitype(Float64) <: SciTypes.Continuous
    @test scitype(ComplexF32) <: SciTypes.Continuous
    @test scitype(ComplexF64) <: SciTypes.Continuous
    @test scitype(1.0) <: SciTypes.Continuous
    @test scitype(1.0f0) <: SciTypes.Continuous
    @test scitype(1.0 + 2im) <: SciTypes.Continuous
    @test scitype(1.0f0 + 2im) <: SciTypes.Continuous

    # Categorical
    @test scitype(Symbol) <: SciTypes.Categorical
    @test scitype(Int) <: SciTypes.Categorical
    @test scitype(String) <: SciTypes.Categorical
    @test scitype(Char) <: SciTypes.Categorical
    @test scitype(:a) <: SciTypes.Categorical
    @test scitype(1) <: SciTypes.Categorical
    @test scitype("a") <: SciTypes.Categorical
    @test scitype('a') <: SciTypes.Categorical
  end

  @testset "elscitype" begin
    # Continuous
    elscitype(1:0.1:3) <: SciTypes.Continuous
    elscitype([1.0, 2.0, 3.0]) <: SciTypes.Continuous
    elscitype([1.0f0, 2.0f0, 3.0f0]) <: SciTypes.Continuous

    # Categorical
    elscitype('a':'z') <: SciTypes.Categorical
  end
end
