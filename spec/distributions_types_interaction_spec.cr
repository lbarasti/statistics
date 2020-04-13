require "./spec_helper"
include Statistics
include Statistics::Distributions

# A function taking an argument of type `Distribution`,
# with no explicit type parameter `T`
def f(d : Distribution(T)) forall T
  d.rand
end

describe Distribution do
  it "resolves the type of expressions returning `Distribution(T)`
      with the most restrictive `T` possible" do
    arr = [] of Float64
    gen = rand < 0.5 ? Normal.new(0.2, 0.5) : Uniform.new(0.2, 0.5)

    arr << gen.rand
  end

  it "when combining `Distribution(T1)` and `Distribution(T2)`, it will
      resolve the returning type to a union type" do
    arr = [] of Float64 | Int32
    ds = [] of Distribution(Int32) | Distribution(Float64)

    gen = rand < 0.5 ? Normal.new(0.2, 0.5) : Poisson.new(2)
    ds << gen

    arr << gen.rand
  end

  it "supports defining functions with parameter of type
      `Distribution(T)`, for all `T`" do
    f(Normal.new(0.2, 0.5))

    f(Poisson.new(0.5))
  end

  it "resolves #pdf calls for `ContinuousDistribution` types" do
    gen = rand < 0.5 ? Normal.new(0.2, 0.5) : Uniform.new(0.2, 0.5)
    gen.pdf(rand) # compiles
  end

  it "resolves #pmf calls for `DiscreteDistribution` types" do
    gen = rand < 0.5 ? Poisson.new(1) : Constant.new(0.2)
    gen.pmf(rand) # compiles
  end
end
