#!/usr/bin/env ruby
require 'benchmark'

def fact(n)
     (1..n).inject(1, :*)
end

p fact(20)
p fact(42)

count = 1000

Benchmark.bm do |x|
  x.report("20!/19!") { count.times { fact(20)/fact(19) == 20 } }
  x.report("100!/99!") { count.times { fact(100)/fact(99) == 100 } }
  x.report("1000!/999!") { count.times { fact(1000)/fact(999) == 1000 } }
end
