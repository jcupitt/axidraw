#!/usr/bin/env ruby

require_relative 'svg'

# a random number between 0 and 1 with gaussian distribution .. just sum 10
# rands
def gnoise
  (1..10).map{rand}.reduce(:+) / 10
end

layer_names = %w[red green blue yellow black purple orange violet polkadot cyan cerise]

width = 1024
height = 707
radius = height / 2
cx = width / 2
cy = height / 2
from = 20
to = radius
range = to - from

# we assign each line to a layer ... pick the nearest, but with a gaussian
# noise fuzz to smooth out transitions
$name_of_number = {}
(0 .. range).step(1).each do |r|
  fuzz_r = r / range.to_f + (gnoise - 0.5) / 2.0
  fuzz_r = [[0.0, fuzz_r].max, 0.99].min
  $name_of_number[x] = layer_names[(fuzz_r * layer_names.length).to_i]
end

def rad(angle)
  2 * Math::PI * angle / 360.0
end

puts "writing circles.svg ..."
File.open "curves.svg", "w" do |file|
  Svg.new file, viewBox: "0 0 #{width} #{height}" do |svg|
    layer_names.each do |name|
      svg.layer name do 
        (0 .. range).step(10).each do |r|
          if name == $name_of_number[r]
            skew = r / range.to_f

            draw = "M #{cx} #{cy - r}"

            (0 ... 5).each do |i|
              angle_step = 2 * Math.PI / 5.0
              angle = i * angle_step
              sx = cx + r * Math.sin(angle_step / 2

              draw += "S #{cx + r * Math.sin(angle_step / 2 } #{cy }, " +
                "#{
            end

            svg.path draw
          end
        end
      end
    end
  end
end

exit

puts "writing curves.svg ..."
File.open "curves.svg", "w" do |file|
  Svg.new file, viewBox: "0 0 1024 707" do |svg|
    layer_names.each do |name|
      svg.layer name do 
        (from .. to).each do |x|
          if name == $name_of_number[x]
            skew = x / 1024.0 - 0.5
            svg.path "M #{x},0" +
              "c #{-300 * skew},180 0,300 #{40 * skew},354" +
              "s #{-100 * skew},180 0,354" 
          end
        end
      end
    end
  end
end

