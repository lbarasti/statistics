require "./spec_helper"
include Statistics
include Statistics::Distributions

tolerance = 0.05 # TODO: adjust this to avoid intermittent failures
sample_size = 100000

describe Constant do
  it "generates the given number, over and over again" do
    const = 3.5
    gen = Constant.new(const)

    values = sample_size.times.map { gen.rand }.to_a

    mean(values).should eq const
    var(values).should eq 0
    skew(values).nan?.should be_true
    kurtosis(values).nan?.should be_true
  end
end

describe Exponential do
  it "generates a number with the given rate parameter" do
    lambda = 2_f64
    gen = Exponential.new(lambda)
    expected = {
      mean: 1/lambda, variance: 1/lambda**2, skewness: 2, kurtosis: 6,
    }

    values = sample_size.times.map { gen.rand }.to_a.sort

    (mean(values) / expected[:mean]).should be_close(1, tolerance)
    (var(values) / expected[:variance]).should be_close(1, tolerance*2)
    (skew(values) / expected[:skewness]).should be_close(1, tolerance*3)
    (kurtosis(values, excess: true) / expected[:kurtosis]).should be_close(1, tolerance*4)
  end
end

describe Normal do
  it "generates a number with the given mean and std" do
    m, std = 0.1, 0.03
    gen = Normal.new(m, std)
    expected = {
      mean: m, variance: std**2, skewness: 0, kurtosis: 0,
    }

    values = sample_size.times.map { gen.rand }.to_a.sort

    (mean(values) / expected[:mean]).should be_close(1, tolerance)
    (var(values) / expected[:variance]).should be_close(1, tolerance)
    skew(values).should be_close(expected[:skewness], tolerance)
    kurtosis(values, excess: true).should be_close(expected[:kurtosis], tolerance*2)
  end
end

describe Poisson do
  it "generates a number with the given arrival rate" do
    lambda = 2_f64
    gen = Poisson.new(lambda)
    expected = {
      mean: lambda, variance: lambda, skewness: lambda**(-0.5), kurtosis: 1/lambda,
    }

    values = sample_size.times.map { gen.rand }.to_a.sort

    (mean(values) / expected[:mean]).should be_close(1, tolerance)
    (var(values) / expected[:variance]).should be_close(1, tolerance)
    (skew(values) / expected[:skewness]).should be_close(1, tolerance*2)
    (kurtosis(values, excess: true) / expected[:kurtosis]).should be_close(1, tolerance*4)
  end
end

describe Uniform do
  it "generates a number in the given interval" do
    min, max = 0.4, 1.2
    gen = Uniform.new(min, max)
    expected = {
      mean:     0.5 * (max + min),
      variance: 1/12 * (max - min)**2,
      skewness: 0,
      kurtosis: -6/5,
    }

    values = sample_size.times.map { gen.rand }.to_a.sort

    (values.max < max).should be_true
    (values.min > min).should be_true

    (mean(values) / expected[:mean]).should be_close(1, tolerance)
    (var(values) / expected[:variance]).should be_close(1, tolerance)
    skew(values).should be_close(expected[:skewness], tolerance)
    (kurtosis(values, excess: true) / expected[:kurtosis]).should be_close(1, tolerance)
  end
end
