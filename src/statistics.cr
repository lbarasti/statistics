require "./lib/distributions"

# TODO: Write documentation for `Statistics`
module Statistics
  extend self
  VERSION = "0.1.0"

  def mean(values)
    values.reduce(0) {|acc, v| acc + v} / values.size
  end
  def var(values, population_mean = nil, corrected = false)
    m = population_mean || Statistics.mean(values)
    size = corrected ? values.size - 1 : values.size
    values.map {|v| (v - m)**2 }.reduce(0) {|a,b| a + b} / size
  end
  def std(values, population_mean = nil, corrected = false)
    Math.sqrt(var(values, population_mean, corrected))
  end
  def describe(values)
    size = values.size
    sorted = values.sort
    {
      mean: mean(values),
      var: var(values),
      std: std(values),
      min: sorted.first,
      max: sorted.last,
      q1: sorted[size//4],
      median: sorted[size//2],
      q3: sorted[size//4*3]
    }
  end
end
