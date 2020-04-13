require "./spec_helper"
include Statistics
include Statistics::Distributions

tolerance = 0.05 # TODO: adjust this to avoid intermittent failures
sample_size = 100000

describe Bernoulli do
  p = 0.8
  q = 1 - p
  gen = Bernoulli.new(p)

  it "returns a success with probability `p`" do
    expected = {
      mean: p, variance: p * q, skewness: (q - p) / Math.sqrt(p * q), kurtosis: (1 - 6 * p * q) / (p * q),
    }

    values = sample_size.times.map { gen.rand }.to_a.sort

    (mean(values) / expected[:mean]).should be_close(1, tolerance)
    (var(values) / expected[:variance]).should be_close(1, tolerance)
    (skew(values) / expected[:skewness]).should be_close(1, tolerance*2)
    (kurtosis(values, excess: true) / expected[:kurtosis]).should be_close(1, tolerance*4)
  end

  it "computes the pmf for a given `x`" do
    gen.pmf(0).should eq q
    gen.pmf(1).should eq p
    gen.pmf(rand).should eq 0
    gen.pmf(rand + 1).should eq 0
    gen.pmf(-rand).should eq 0
  end
end

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

  it "computes the pmf for a given `x`" do
    c = Constant.new(k = rand * 10)
    c.pmf(k).should eq 1
    c.pmf(k + 10 * rand).should eq 0
    c.pmf(k - 10 * rand).should eq 0
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

  it "computes the pdf for a given `x`" do
    lambda = rand * 2
    e = Exponential.new(lambda)
    e.pdf(-rand).should eq 0.0
    e.pdf(0).should eq lambda
    e.pdf(1 / lambda).should be_close(lambda / Math::E, 1e-8)
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

  it "computes the pdf for a given `x`" do
    # https://en.wikipedia.org/wiki/Normal_distribution#Numerical_approximations_for_the_normal_CDF
    # see also https://www.ijser.org/researchpaper/Approximations-to-Standard-Normal-Distribution-Function.pdf
    n = Normal.new
    b0 = 0.2316419; b1 = 0.319381530; b2 = -0.356563782; b3 = 1.781477937; b4 = -1.821255978; b5 = 1.330274429

    cum = ->(x : Float64) {
      t = 1 / (1 + b0 * x)
      1 - n.pdf(x) * (b1 * t + b2 * t**2 + b3 * t**3 + b4 * t**4 + b5 * t**5)
    }
    cum.call(0.0).should be_close 0.5, 10e-5
    (cum.call(1.0) - (1 - cum.call(1.0))).should be_close 0.6827, 10e-5
    cum.call(0.6745).should be_close 0.75, 10e-5
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

  it "computes the pmf for a given `x`" do
    Poisson.new(1).pmf(1).should be_close 0.36, 0.01
    Poisson.new(1).pmf(0).should eq Poisson.new(1).pmf(1)
    Poisson.new(1).pmf(25).should be_close 0, 1e-16

    Poisson.new(4).pmf(4).should eq Poisson.new(4).pmf(3)
    Poisson.new(4).pmf(4).should be_close 0.19, 0.01
    (Poisson.new(4).pmf(1) < 0.08).should be_true

    # pmf outside of Poisson's support
    Poisson.new(1).pmf(0.8).should eq 0
    Poisson.new(1).pmf(-2).should eq 0
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

  it "computes the pdf for a given `x`" do
    min, max = rand, rand + 1
    u = Uniform.new(min, max)
    u.pdf(u.rand).should eq 1 / (max - min)
    u.pdf(min - rand).should eq 0.0
    u.pdf(max + rand).should eq 0.0
  end
end
