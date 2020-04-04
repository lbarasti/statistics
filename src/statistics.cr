require "./lib/distributions"

# Basic descriptive statistics functionality.
#
# More flexible than a scientific-calculator, but not as exhaustive, yet.
module Statistics
  extend self
  VERSION = "0.2.0"

  # Computes several descriptive statistics of the passed array.
  #
  # Parameters
  # - values: a one-dimensional dataset.
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
      middle:   middle(sorted),
      max:      sorted.last,
      q1:       quantile(sorted, 0.25, sorted: true),
      median:   median(sorted, sorted: true),
      q3:       quantile(sorted, 0.75, sorted: true),
    }
  end

  # Computes the number of occurrences of each value in the dataset.
  #
  # Returns a Hash with each the dataset values as keys and the number of times they appear as value.
  #
  # Parameters
  # - values: a one-dimensional dataset
  def frequency(values : Enumerable(T)) forall T
    values.reduce(Hash(T, Int32).new(0)) { |freq, v|
      freq[v] += 1
      freq
    }
  end

  # Computes the kurtosis of a dataset.
  #
  # Parameters
  # - values: a one-dimensional dataset.
  # - corrected: when set to `true`, then the calculations are corrected for statistical bias. Default is `false`.
  # - excess: when set to `true`, computes the [excess kurtosis](https://en.wikipedia.org/wiki/Kurtosis#Excess_kurtosis). Default is `false`.
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
  # - values: a one-dimensional dataset.
  def mean(values)
    values.reduce(0) { |acc, v| acc + v } / values.size
  end

  # Computes the median of all elements in a dataset.
  #
  # For an even number of elements the mean of the two median elements will be computed.
  #
  # Parameters
  # - values: a one-dimensional dataset.
  # - sorted: when `true`, the computations assume that the provided values are
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
  # - values: a one-dimensional dataset.
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

  # Computes the modal (most common) value in a dataset.
  #
  # Returns a pair with the modal value and the bin-count for the modal bin.
  # If there is more than one such value, no guarantees are made which one will be picked.
  # NOTE: Computing the mode requires traversing the entire dataset.
  #
  # Parameters
  # - values: a one-dimensional dataset.
  def mode(values : Enumerable)
    frequency(values).max_by(&.last)
  end

  # Calculates the n-th moment about the mean for a sample.
  #
  # Parameters
  # - values: a one-dimensional dataset.
  # - mean: a pre-computed mean. If a mean is not provided, then the sample's
  #   mean will be computed. Default is `nil`.
  # - n: order of central moment that is returned. Default is `1`.
  def moment(values, mean = nil, n = 1)
    m = mean || Statistics.mean(values)
    values.reduce(0) { |a, b| a + (b - m)**n } / values.size
  end

  # Computes the quantile of a dataset at a specified probability `p` on the interval [0,1].
  #
  # Quantiles are computed via linear interpolation between the points `((k-1)/(n-1), v[k])`,
  # for `k = 1:n` where `n = values.size`.
  #
  # Parameters
  # - values: a one-dimensional dataset.
  # - p: probability. Values of `p` should be in the interval `[0, 1]`.
  # - sorted indicates whether values can be assumed to be sorted.
  #
  # Implementation based on Julia's [Statistics.quantile](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.quantile).
  def quantile(values, p, sorted = false)
    sorted_values = sorted ? values : values.sort
    n = values.size
    aleph = (n - 1) * p
    j = clamp(aleph.floor, 0, n - 2).to_i
    gamma = clamp(aleph - j, 0, 1)

    a = sorted_values[j]
    b = sorted_values[j + 1]

    a + (b - a) * gamma
  end

  # Computes the skewness of a dataset.
  #
  # Parameters
  # - values: a one-dimensional dataset.
  # - corrected: when set to `true`, then the calculations are corrected for statistical bias. Default is `false`.
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
  # - values: a one-dimensional dataset.
  # - mean: a pre-computed mean. This could be a pre-computed sample's mean
  #   or the population's known mean. If a mean is not provided, then the sample's
  #   mean will be computed. Default is `nil`.
  # - corrected: when set to `true`, then the sum of squares is scaled
  #   with `values.size - 1`, rather than with `values.size`. Default is `false`.
  def std(values, mean = nil, corrected = false)
    Math.sqrt(var(values, mean, corrected))
  end

  # Computes the variance of a dataset.
  #
  # Parameters
  # - values: a one-dimensional dataset.
  # - mean: a pre-computed mean. This could be a pre-computed sample's mean
  #   or the population's known mean. If a mean is not provided, then the sample's
  #   mean will be computed. Default is `nil`.
  # - corrected: when set to `true`, then the sum of squares is scaled
  #   with `values.size - 1`, rather than with `values.size`. Default is `false`.
  def var(values, mean = nil, corrected = false)
    correction_factor = corrected ? values.size / (values.size - 1) : 1

    moment(values, mean, 2) * correction_factor
  end

  private def clamp(x, min, max)
    x < min ? min : x < max ? x : max
  end
end
