module Statistics
  module Distributions
    abstract class Distribution(T)
      # Samples a random variable with the given distribution.
      abstract def rand : T
    end

    abstract class DiscreteDistribution(T) < Distribution(T)
      # The Probability Mass Function (PMF) of a discrete
      # random variable.
      abstract def pmf(x)
    end

    abstract class ContinuousDistribution < Distribution(Float64)
      # The Probability Density Function (PDF) of a continuous
      # random variable.
      abstract def pdf(x)
    end

    # The discrete probability distribution of a random variable which takes
    # the value 1 with probability `p` and the value 0 with probability
    # `q=1-p` (source: [wikipedia](https://en.wikipedia.org/wiki/Bernoulli_distribution)).
    class Bernoulli < DiscreteDistribution(Int32)
      # Creates Bernoulli distribution with success rate `p`.
      def initialize(@p : Float64)
      end

      def pmf(x)
        case x
        when 1 then @p
        when 0 then 1 - @p
        else        0
        end
      end

      def rand : Int32
        ::rand <= @p ? 1 : 0
      end
    end

    # Represents a deterministic distribution taking a single value.
    class Constant < DiscreteDistribution(Float64)
      getter rand : Float64

      def pmf(x)
        x == @rand ? 1.0 : 0.0
      end

      # Creates a degenerate distribution which only takes the value `k`.
      def initialize(k @rand : Float64)
      end
    end

    # Represents the probability distribution of the time between events in
    # a Poisson point process, i.e., a process in which events occur continuously
    # and independently at a constant average rate.
    #
    # See [wikipedia](https://en.wikipedia.org/wiki/Exponential_distribution) for more details.
    class Exponential < ContinuousDistribution
      # Creates an exponential distribution with a rate parameter `lambda`.
      def initialize(@lambda : Float64)
      end

      def pdf(x)
        return 0.0 if x < 0
        # \lambda e^{{-\lambda x}}
        @lambda * Math.exp(-@lambda * x)
      end

      def rand : Float64
        # https://en.wikipedia.org/wiki/Inverse_transform_sampling
        # https://stackoverflow.com/questions/2106503/pseudorandom-number-generator-exponential-distribution/2106564

        -Math.log(::rand) / @lambda
      end
    end

    # Represents a normal distribution.
    #
    # See [wikipedia](https://en.wikipedia.org/wiki/Normal_distribution) for more details.
    class Normal < ContinuousDistribution
      TWO_PI          = 2 * Math::PI
      PDF_COEFFICIENT = 1 / Math.sqrt(TWO_PI)

      # Creates a normal distribution with the given `mean` and `std`.
      def initialize(@mean : Float64 = 0, @std : Float64 = 1)
      end

      def pdf(x)
        exponent = -0.5 * ((x - @mean) / @std)**2
        PDF_COEFFICIENT / @std * Math.exp(exponent)
      end

      def rand : Float64
        # https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform

        v = Math.sqrt(-2 * Math.log(::rand)) * Math.sin(TWO_PI * ::rand)
        v * @std + @mean
      end
    end

    # Represents a discrete probability distribution that expresses
    # the probability of a given number of events occurring in a
    # fixed interval of time or space if these events occur with a
    # known constant mean rate and independently of the time since
    # the last event (source: [wikipedia](https://en.wikipedia.org/wiki/Poisson_distribution))
    class Poisson < DiscreteDistribution(Int32)
      # Creates a Poisson distribution with expected value `lambda`.
      def initialize(@lambda : Float64)
      end

      def pmf(x)
        return 0.0 if x - x.round(0) != 0
        return 0.0 if x < 0
        acc = 1
        x.to_i.times { |i|
          acc = acc * @lambda / (i + 1)
        }
        acc * Math.exp(-@lambda)
      end

      def rand : Int32
        # see https://en.wikipedia.org/wiki/Poisson_distribution#Generating_Poisson-distributed_random_variables
        # https://www.johndcook.com/SimpleRNG.cpp
        # https://www.johndcook.com/blog/2010/06/14/generating-poisson-random-values/

        x = 0
        p = Math.exp(-@lambda)
        s = p
        u = ::rand
        while u > s
          x += 1
          p *= @lambda / x
          s += p
        end
        x
      end
    end

    # Represents a continuous uniform distribution.
    #
    # See [wikipedia](https://en.wikipedia.org/wiki/Uniform_distribution_(continuous).
    class Uniform < ContinuousDistribution
      @interval : Float64

      # Creates a uniform distribution within the interval [`min`, `max`].
      def initialize(@min : Float64, @max : Float64)
        @interval = @max - @min
      end

      def pdf(x)
        if @min <= x && x <= @max
          1 / @interval
        else
          0.0
        end
      end

      def rand : Float64
        @min + ::rand * @interval
      end
    end
  end
end
