require "./lib/distributions"

# Basic descriptive statistics functionality.
#
# More flexible than a scientific-calculator, but not as exhaustive, yet.
module Statistics
  extend self
  VERSION = "0.1.0"

  # Computes several descriptive statistics of the passed array.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  def describe(values)
    size = values.size
    sorted = values.sort
    {
      mean:     mean(values),
      var:      var(values),
      std:      std(values),
      skewness: skew(values),
      kurtosis: kurtosis(values),
      min:      sorted.first,
      max:      sorted.last,
      q1:       sorted[size//4],
      median:   median(sorted, sorted: true),
      middle:   middle(sorted),
      q3:       sorted[size//4*3],
    }
  end

  # Computes the kurtosis of a dataset.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  # - `corrected`: when set to `true`, then the calculations are corrected for statistical bias. Default is `false`.
  # - `excess`: when set to `true`, computes the [excess kurtosis](https://en.wikipedia.org/wiki/Kurtosis#Excess_kurtosis). Default is `false`.
  #
  # This implementation is based on the [scipy/stats.py](https://github.com/scipy/scipy/blob/3de0d58/scipy/stats/stats.py#L1142).
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

  # Computes the mean of a dataset.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  def mean(values)
    values.reduce(0) { |acc, v| acc + v } / values.size
  end

  # Computes the median of all elements in a dataset. For an even number of
  # elements the mean of the two median elements will be computed.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  # - `sorted`: when `true`, the computations assume that the provided values are
  #   sorted. Default is `false`.
  #
  # See Julia's [Statistics.median](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.median).
  def median(values, sorted = false)
    size = values.size
    mid = size // 2
    sorted_values = sorted ? values : values.sort

    if size.odd?
      sorted_values[mid]
    else
      middle([sorted_values[mid - 1], sorted_values[mid]])
    end
  end

  # Computes the middle of an array `a`, which consists of finding its
  # extrema and then computing their mean.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  #
  # See Julia's [Statistics.middle](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.middle).
  def middle(values)
    min, max = values.minmax
    middle(min, max)
  end

  # Computes the middle of two values `a` and `b`.
  def middle(a, b)
    0.5 * (a + b)
  end

  # Calculates the n-th moment about the mean for a sample.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  # - `mean`: a pre-computed mean. If a mean is not provided, then the sample's
  #   mean will be computed. Default is `nil`.
  # - `n`: Order of central moment that is returned. Default is `1`.
  def moment(values, mean = nil, n = 1)
    m = mean || Statistics.mean(values)
    values.reduce(0) { |a, b| a + (b - m)**n } / values.size
  end

  # Computes the skewness of a dataset.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  # - `corrected`: when set to `true`, then the calculations are corrected for statistical bias. Default is `false`.
  #
  # This implementation is based on the [scipy/stats.py](https://github.com/scipy/scipy/blob/3de0d58/scipy/stats/stats.py#L1039).
  def skew(values, corrected = false)
    n = values.size
    m = mean(values)
    m3 = moment(values, m, 3)
    m2 = moment(values, m, 2)
    correction_factor = corrected ? Math.sqrt((n - 1.0) * n) / (n - 2.0) : 1
    correction_factor * m3 / m2**1.5
  end

  # Computes the standard deviation of a dataset.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  # - `mean`: a pre-computed `mean`. This could be a pre-computed sample's mean
  #   or the population's known mean. If a mean is not provided, then the sample's
  #   mean will be computed. Default is `nil`.
  # - `corrected`: when set to `true`, then the sum of squares is scaled
  #   with `values.size - 1`, rather than with `values.size`. Default is `false`.
  def std(values, mean = nil, corrected = false)
    Math.sqrt(var(values, mean, corrected))
  end

  # Computes the variance of a dataset.
  #
  # Parameters
  # - `values`: a one-dimensional dataset.
  # - `mean`: a pre-computed `mean`. This could be a pre-computed sample's mean
  #   or the population's known mean. If a mean is not provided, then the sample's
  #   mean will be computed. Default is `nil`.
  # - `corrected`: when set to `true`, then the sum of squares is scaled
  #   with `values.size - 1`, rather than with `values.size`. Default is `false`.
  def var(values, mean = nil, corrected = false)
    correction_factor = corrected ? values.size / (values.size - 1) : 1

    moment(values, mean, 2) * correction_factor
  end
end
