[![GitHub release](https://img.shields.io/github/release/lbarasti/statistics.svg)](https://github.com/lbarasti/statistics/releases)
![Build Status](https://github.com/lbarasti/statistics/workflows/build/badge.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://lbarasti.github.io/statistics)

# statistics

A statistical library to perform descriptive statistics and generate random values based on popular probability distributions.

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  statistics:
    github: lbarasti/statistics
```

Run `shards install`

## Usage

```crystal
require "statistics"
```

### Descriptive statistics
You can compute mean, variance and standard deviation of a collection as follows.
```crystal
include Statistics

x = [1, 10, 7]
mean(x) # 6
var(x) # 14
std(x) # 3.7416...
```

If you'd like to know a bit more about your dataset, you can simply `describe` it

```crystal
x = (1..1000).map { rand }.to_a # a uniformely distributed dataset
describe(x)
# {
#   mean: 0.48, var: 0.08, std: 0.28, 
#   skewness: 0.04, kurtosis: 1.81, 
#   min: 0.01, middle: 0.49, max: 0.99, 
#   q1: 0.24, median: 0.49, q3: 0.73
# }
```

`Statistics.describe` returns a `NamedTuple`, so you can extract any value via indexing:

```crystal
stats = describe(x)
stats[:q1] # returns the first quartile of your sample
```

For a complete list of the statistical functions provided, including `quantile`, `moment` and `skew`, check out the [docs](https://lbarasti.com/statistics/Statistics.html).

### Sampling
To work with distributions, import the `Distributions` namespace as follows.
```crystal
include Statistics::Distributions
```

Now, here is how we sample values from a normal distribution with `mean = 1.5` and `std = 0.2`.
```crystal
Normal.new(1.5, 0.2).rand
```

We can generate an iterable of normally distributed random values as follows.
```crystal
gen = Normal.new(1.5, 0.2)
1000.times.map { gen.rand }
```

#### Supported distributions
The following distributions are supported:
* Constant
* Exponential
* Normal
* Poisson
* Uniform

Don't see your favourite one on the list? Just fork the repo, add your distribution to the `distributions.cr` file, and open a PR.

## Development

This shard is a work in progress. Everyone's contribution is welcome.

The guiding principle at this stage is
> make it work before you make it right

Which in this context means: let's not focus on benchmarks and performance, but rather on usability and correctness.

## References
* [numpy.random](https://numpy.org/devdocs/reference/random/generator.html): distributions and random sampling
* [numpy statistics](https://numpy.org/devdocs/reference/routines.statistics.html#averages-and-variances): order statistics, averages and variances
* [scipy stats](https://github.com/scipy/scipy/blob/3de0d58/scipy/stats/stats.py) module and related [tests](https://github.com/scipy/scipy/blob/1150c4c033899a5a4556b7d34d6b137352b36b9e/scipy/stats/tests/test_stats.py) tests
* [julia random](https://docs.julialang.org/en/v1/stdlib/Random/) module
* [julia statistics](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.std) module
* [julia distributions](https://juliastats.org/Distributions.jl/latest/starting/) package.
* on [skewness and kurtosis](https://brownmath.com/stat/shape.htm), by Stan Brown
* more on [skewness and kurtosis](https://www.itl.nist.gov/div898/handbook/eda/section3/eda35b.htm), from NIST.

## Contributing

1. Fork it (<https://github.com/lbarasti/statistics/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [lbarasti](https://github.com/lbarasti) - creator and maintainer
