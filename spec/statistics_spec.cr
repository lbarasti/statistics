require "./spec_helper"
include Statistics

describe Statistics do
  it "can describe a simple collection" do
    x = [1, 10, 7]

    expected_mean = 6
    expected_var = 14
    expected_var_corrected = 21
    expected_varp = 18

    mean(x).should eq expected_mean
    var(x).should eq expected_var
    var(x, corrected: true).should eq expected_var_corrected
    var(x, mean: 8).should eq expected_varp
    std(x).should eq Math.sqrt(var(x))
  end

  it "can describe a collection of consecutive numbers" do
    sample_size = 353
    x = (1..sample_size).to_a

    expected_mean = (sample_size + 1) * sample_size / 2 / sample_size
    expected_var = 10384

    mean(x).should eq expected_mean
    var(x).should eq expected_var
  end

  it "can compute the skew of a sample" do
    # Scipy from https://github.com/scipy/scipy/blob/3de0d58/scipy/stats/stats.py#L1106
    skew([1, 2, 3, 4, 5]).should eq 0.0
    skew([2, 8, 0, 4, 1, 9, 9, 0]).should eq 0.2650554122698573
    # from Scipy https://github.com/scipy/scipy/blob/1150c4c033899a5a4556b7d34d6b137352b36b9e/scipy/stats/tests/test_stats.py#L2256
    sample = [1.165, 0.6268, 0.0751, 0.3516, -0.6965]
    skew(sample).should be_close(-0.29322304336607, 0.000001)
    skew(sample, corrected: true).should be_close(-0.437111105023940, 0.000001)
  end

  it "can compute the kurtosis of a sample" do
    # # Scipy from https://github.com/scipy/scipy/blob/3de0d58/scipy/stats/stats.py#L1106
    # kurtosis([1, 2, 3, 4, 5]).should eq 0.0
    # kurtosis([2, 8, 0, 4, 1, 9, 9, 0]).should eq 0.2650554122698573
    # https://github.com/scipy/scipy/blob/1150c4c033899a5a4556b7d34d6b137352b36b9e/scipy/stats/tests/test_stats.py#L2291
    sample = [1.165, 0.6268, 0.0751, 0.3516, -0.6965]
    kurtosis(sample).should be_close(2.1658856802973, 0.000001)
    kurtosis(sample, corrected: true).should be_close(3.663542721189047, 0.000001)

    kurtosis([1, 2, 3, 4]).should eq 1.64
  end

  it "can compute the middle of a sample" do
    middle([2.3]).should eq 2.3
    middle([2.6, 3.4]).should eq 3.0
    middle([5.5, 1.2, 5.5]).should eq middle([1.2, 5.5])
    # From https://github.com/JuliaLang/Statistics.jl/blob/master/src/Statistics.jl#L750
    middle([1, 2, 3.6, 10.9]).should eq 5.95
  end

  it "can compute the median of a sample" do
    median([2.3]).should eq 2.3
    median([2.6, 3.4]).should eq 3.0
    median([5.5, 1.2, 5.5]).should eq 5.5
    median([5.5, 1.2, 5.5, 3.5, 10.2, 5.5]).should eq 5.5
    # From https://github.com/JuliaLang/Statistics.jl/blob/master/src/Statistics.jl#L750
    median([1, 2, 3.6, 10.9]).should eq middle(2, 3.6)

    median((1..10).to_a.shuffle).should eq 5.5
    median((1..11).to_a.shuffle).should eq 6
  end

  it "can compute the quantile `p` of a sample" do
    sample = (0..20).to_a
    quantile(sample, 0.5).should eq 10
    quantile(sample, 0.1).should eq 2
    quantile(sample, 0.9).should eq 18
    quantile(sample, 0).should eq 0
    quantile(sample, 1).should eq 20

    quantile([1, 2, 3], 0.5).should eq median([1, 2, 3])
    quantile([1, 2, 3], 0).should eq 1
    quantile([1, 2, 3], 1).should eq 3

    quantile([1, 10], 0.5).should eq 5.5

    quantile([42], 0).should eq 42
    quantile([42], 0.2).should eq 42
    quantile([42], 1).should eq 42
  end

  it "can compute the mode and frequency hash of a sample" do
    sample = [1, 1, 7, 7, 1, 5, 3, 6, 7, 6, 7, 10]
    m, c = mode(sample)
    m.should eq 7
    c.should eq 4

    f = frequency(sample)
    f[1].should eq 3
    f[10].should eq 1
    f.max_by(&.last).first.should eq m
  end

  describe ".bin_count" do
    sample = [1, 1, 7, 7, 1, 5, 3, 6, 7, 6, 7, 10]

    it "can compute an arbitrary number of bins for a sample" do
      transposed_bin_count(sample, 1).should eq [{1.0, sample.size}]
      transposed_bin_count(sample, 2).should eq [{1.0, 5}, {5.5, 7}]

      transposed_bin_count(0..3, 3).should eq [{0.0, 1}, {1.0, 1}, {2.0, 2}]
    end

    it "returns an array {edge, count} tuples sorted by edge" do
      edges = transposed_bin_count(sample, 5).map(&.first)
      edges.size.should eq 5
      edges.each_cons(2) { |(a, b)|
        (a < b).should be_true
      }
    end

    it "includes bins where the count is zero" do
      transposed_bin_count([1, 2, 7], 3).should eq [{1.0, 2}, {3.0, 0}, {5.0, 1}]
    end

    it "supports specifying the min and max edges" do
      transposed_bin_count([0.5, 1.5, 2.5], 3, min: 0, max: 3).should eq [{0.0, 1}, {1.0, 1}, {2.0, 1}]
      transposed_bin_count(0..3, 3, max: 6).should eq [{0.0, 2}, {2.0, 2}, {4.0, 0}]
    end

    it "supports specifying which edge point should be returned" do
      bins = 5
      step = (sample.max - sample.min) / bins

      left = bin_count(sample, bins, edge: :left).edges
      centre = bin_count(sample, bins, edge: :centre).edges
      right = bin_count(sample, bins, edge: :right).edges
      left.zip(centre).each { |l, c| (l - c + step / 2).should be_close 0, 1e-15 }
      left.zip(right).each { |l, r| (l - r + step).should be_close 0, 1e-15 }
    end
  end
end
