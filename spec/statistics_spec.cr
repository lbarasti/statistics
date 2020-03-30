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
    var(x, population_mean: 8).should eq expected_varp
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
end
