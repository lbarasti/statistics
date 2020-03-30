module Statistics
  module Distributions
    class Constant
      property rand

      def initialize(@rand : Float64)
      end
    end

    class Exponential
      # https://en.wikipedia.org/wiki/Inverse_transform_sampling
      # https://stackoverflow.com/questions/2106503/pseudorandom-number-generator-exponential-distribution/2106564
      def initialize(@lambda : Float64)
      end

      def rand
        -Math.log(::rand) / @lambda
      end
    end

    class Normal
      # https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
      TWO_PI = 2 * Math::PI

      def initialize(@mean : Float64, @std : Float64)
      end

      def rand
        v = Math.sqrt(-2 * Math.log(::rand)) * Math.sin(TWO_PI * ::rand)
        v * @std + @mean
      end
    end

    class Poisson
      # see https://en.wikipedia.org/wiki/Poisson_distribution#Generating_Poisson-distributed_random_variables
      # https://www.johndcook.com/SimpleRNG.cpp
      # https://www.johndcook.com/blog/2010/06/14/generating-poisson-random-values/
      def initialize(@lambda : Float64)
      end

      def rand
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

    class Uniform
      @interval : Float64

      def initialize(@min : Float64, max : Float64)
        @interval = max - @min
      end

      def rand
        @min + ::rand * @interval
      end
    end
  end
end
