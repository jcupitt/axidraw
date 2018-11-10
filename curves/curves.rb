#!/usr/bin/env ruby

$: << File.dirname(__FILE__) 
require 'svg'

# a random number between 0 and 1 with gaussian distribution .. just sum 10
# rands
def gnoise
  (1..10).map{rand}.reduce(:+) / 10
end

layers = %w[red, green, blue, yellow, black, purple, orange]

# we assign each line to a layer ... pick the nearest, but with a gaussian
# noise fuzz to smooth out transitions
layer_of_number = {}
(0..1024).step(2).each do |x|
  fuzz_x = x / 1024.0 + (gnoise - 0.5) / 3.0
  fuzz_x = [[0.0, fuzz_x].max, 0.99].min
  layer_of_number[x] = layers[(fuzz_x * layers.length).to_i]
end

puts "writing x.svg ..."
File.open "x.svg", "w" do |s|
  Svg.new s, viewBox: "0 0 1024 656" do |svg|
    layers.each do |layer_name|
      svg.layer layer_name do |svg| 
        (0..1024).step(2).each do |x|
          if layer_name == layer_of_number[x]
            svg.path "M #{x} 0 L #{x} 656"
          end
        end
      end
    end
  end
end
