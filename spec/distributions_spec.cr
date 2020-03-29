require "./spec_helper"
include Statistics
include Statistics::Distributions

tolerance = 0.05 # TODO: adjust this to avoid intermittent failures
sample_size = 10000

describe Constant do
  it "generates the given number, over and over again" do
    const = 3.5
    gen = Constant.new(const)

    values = sample_size.times.map { gen.rand }.to_a

    mean(values).should eq const
    var(values).should eq 0
  end
end

describe Exponential do
  it "generates a number with the given rate parameter" do
    lambda = 2_f64
    gen = Exponential.new(lambda)

    values = sample_size.times.map { gen.rand }.to_a.sort

    (mean(values) / (1 / lambda)).should be_close(1, tolerance)
    (var(values) / (1 / lambda**2)).should be_close(1, tolerance)
  end
end

describe Normal do
  it "generates a number with the given mean and std" do
    m, std = 0.1, 0.03
    gen = Normal.new(m, std)

    values = sample_size.times.map { gen.rand }.to_a.sort

    (mean(values) / m).should be_close(1, tolerance)
    (var(values) / std**2).should be_close(1, tolerance)
  end
end

describe Poisson do
  it "generates a number with the given arrival rate" do
    lambda = 2_f64
    gen = Poisson.new(lambda)

    values = sample_size.times.map { gen.rand }.to_a.sort

    (mean(values) / lambda).should be_close(1, tolerance)
    (var(values) / lambda).should be_close(1, tolerance)
  end
end

describe Uniform do
  it "generates a number in the given interval" do
    min, max = 0.4, 1.2
    gen = Uniform.new(min, max)

    values = sample_size.times.map { gen.rand }.to_a.sort

    (values.max < max).should be_true
    (values.min > min).should be_true

    m = 0.5 * (max + min)
    var = 1/12 * (max - min) * (max - min)

    (mean(values) / m).should be_close(1, tolerance)
    (var(values) / var).should be_close(1, tolerance)
  end
end
