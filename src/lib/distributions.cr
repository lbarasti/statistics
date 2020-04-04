module Statistics
  module Distributions
    abstract class Distribution(T)
      # Samples a random variable with the given distribution.
      abstract def rand : T
    end

    # Represents a deterministic distribution taking a single value.
    class Constant < Distribution(Float64)
      getter rand : Float64

      # Creates a degenerate distribution which only takes the value `k`.
      def initialize(k @rand : Float64)
      end
    end

    # Represents the probability distribution of the time between events in
    # a Poisson point process, i.e., a process in which events occur continuously
    # and independently at a constant average rate.
    #
    # See [wikipedia](https://en.wikipedia.org/wiki/Exponential_distribution) for more details.
    class Exponential < Distribution(Float64)
      # Creates an exponential distribution with a rate parameter `lambda`.
      def initialize(@lambda : Float64)
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
    class Normal < Distribution(Float64)
      TWO_PI = 2 * Math::PI

      # Creates a normal distribution with the given `mean` and `std`.
      def initialize(@mean : Float64, @std : Float64)
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
    class Poisson < Distribution(Int32)
      # Creates a Poisson distribution with expected value `lambda`.
      def initialize(@lambda : Float64)
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
    class Uniform < Distribution(Float64)
      @interval : Float64

      # Creates a uniform distribution within the interval [`min`, `max`].
      def initialize(@min : Float64, max : Float64)
        @interval = max - @min
      end

      def rand : Float64
        @min + ::rand * @interval
      end
    end
  end
end
