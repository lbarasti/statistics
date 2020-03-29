# statistics

TODO: Write a description here

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  statistics:
    github: lbarasti/statistics
```

2. Run `shards install`

## Usage

```crystal
require "statistics"
```

### Descriptive statistics
TODO

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

## Contributing

1. Fork it (<https://github.com/lbarasti/statistics/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [lbarasti](https://github.com/lbarasti) - creator and maintainer
