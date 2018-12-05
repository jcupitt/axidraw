#!/usr/bin/env ruby

$: << File.dirname(__FILE__) 
require 'svg'

# a random number between 0 and 1 with gaussian distribution .. just sum 10
# rands
def gnoise
  (1..10).map{rand}.reduce(:+) / 10
end

layer_names = %w[red green blue yellow black purple orange violet polkadot cyan cerise]

# the x range we make lines over ... we have to go over 1024 and under 0 to
# paint the edges
from = -100
to = 1100

# we assign each line to a layer ... pick the nearest, but with a gaussian
# noise fuzz to smooth out transitions
name_of_number = {}
(from..to).step(1).each do |x|
  fuzz_x = x / 1024.0 + (gnoise - 0.5) / 2.0
  fuzz_x = [[0.0, fuzz_x].max, 0.99].min
  name_of_number[x] = layer_names[(fuzz_x * layer_names.length).to_i]
end

# the plot area is 420x295mm and we must have the same aspect ratio or we'll see
# clipping bugs
puts "writing curves.svg ..."
File.open "curves.svg", "w" do |file|
  Svg.new file, viewBox: "0 0 1024 720" do |svg|
    layer_names.each do |name|
      svg.layer name do 
        (from..to).step(1).each do |x|
          if name == name_of_number[x]
            skew = x / 1024.0 - 0.5
            svg.path "M #{x},0" +
              "c #{-300 * skew},180 0,300 #{40 * skew},360" +
              "s #{-100 * skew},180 0,360" 
          end
        end
      end
    end
  end
end
