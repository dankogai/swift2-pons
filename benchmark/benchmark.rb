#!/usr/bin/env ruby
require 'benchmark'

def fact(n)
     (1..n).inject(1, :*)
end

p fact(20)
p fact(42)

count = 10000

Benchmark.bm do |x|
  x.report("20!/19!")  { count.times {fact(20)/fact(19) == 20 } }
  x.report("100!/99!") { count.times {fact(100)/fact(99) == 100 } }
end
