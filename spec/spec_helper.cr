require "spec"
require "../src/statistics"

def transposed_bin_count(sample, bins : Int32, min = nil, max = nil)
  obj = bin_count(sample, bins, min, max)
  obj.edges.map_with_index { |e, i| {e, obj.counts[i]} }
end
