require "./lib/distributions"

# TODO: Write documentation for `Statistics`
module Statistics
  extend self
  VERSION = "0.1.0"

  def describe(values)
    size = values.size
    sorted = values.sort
    {
      mean:   mean(values),
      var:    var(values),
      std:    std(values),
      min:    sorted.first,
      max:    sorted.last,
      q1:     sorted[size//4],
      median: sorted[size//2],
      q3:     sorted[size//4*3],
    }
  end

  # Computes the kurtosis of a dataset.
  #
  # Parameters
  # - `values`: a one-dimensional dataset
  # - `corrected`: when set to `true`, then the calculations are corrected for statistical bias.
  # - `excess`: when set to `true`, computes the [excess kurtosis](https://en.wikipedia.org/wiki/Kurtosis#Excess_kurtosis).
  #
  # This implementation is based on the [scipy/stats.py](https://github.com/scipy/scipy/blob/3de0d58/scipy/stats/stats.py#L1142)
  def kurtosis(values, corrected = false, excess = false)
    n = values.size
    m = mean(values)
    m4 = moment(values, m, 4)
    m2 = moment(values, m, 2)

    kurt = if corrected
             1 / (n - 2) / (n - 3) * ((n**2 - 1) * m4 / m2**2 - 3 * (n - 1)**2) + 3
           else
             m4 / m2**2
           end

    excess ? kurt - 3 : kurt
  end

  def mean(values)
    values.reduce(0) { |acc, v| acc + v } / values.size
  end

  def moment(values, mean, n)
    values.reduce(0) { |a, b| a + (b - mean)**n } / values.size
  end

  # Computes the skewness of a dataset.
  #
  # Parameters
  # - `values`: a one-dimensional dataset
  # - `corrected`: when set to `true`, then the calculations are corrected for statistical bias.
  #
  # This implementation is based on the [scipy/stats.py](https://github.com/scipy/scipy/blob/3de0d58/scipy/stats/stats.py#L1039)
  def skew(values, corrected = false)
    n = values.size
    m = mean(values)
    m3 = moment(values, m, 3)
    m2 = moment(values, m, 2)
    correction_factor = corrected ? Math.sqrt((n - 1.0) * n) / (n - 2.0) : 1
    correction_factor * m3 / m2**1.5
  end

  def std(values, population_mean = nil, corrected = false)
    Math.sqrt(var(values, population_mean, corrected))
  end

  def var(values, population_mean = nil, corrected = false)
    m = population_mean || Statistics.mean(values)

    correction_factor = corrected ? values.size / (values.size - 1) : 1

    moment(values, m, 2) * correction_factor
  end
end
