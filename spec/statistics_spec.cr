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
    
    expected_mean = (sample_size+1) * sample_size / 2 / sample_size
    expected_var = 10384

    mean(x).should eq expected_mean
    var(x).should eq expected_var
  end

end