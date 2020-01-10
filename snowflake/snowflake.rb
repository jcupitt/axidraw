#!/usr/bin/env ruby

require 'prime'

require_relative 'svg'

$radius = 5
$spacing = 6
$layer_names = %w[red green blue yellow black purple orange violet magenta cyan teal]
$n_layers = 60

def rad angle
  2.0 * Math::PI * angle / 360.0
end

def add(a, b)
  a.zip(b).map{|(x, y)| x + y}
end

def total_tiles(layer, n)
  prior = 1 + (0 ... layer).map{|x| x * 6}.sum

  edge = 0

  # the zero tile
  if layer > 0 
    edge += 1 
  end

  # a second zero tile
  if layer > 2 && layer % 2 == 1
    edge += 1 
  end

  # double extra tiles
  if layer > 1 && n > 0
    edge += 2 * n
  end

  if layer > 1 && n == layer / 2
    edge -= 1
  end

  prior + edge * 6
end

(0 ... $n_layers).each do |layer|
  row = []
  (0 .. layer / 2).each do |i|
    total = total_tiles layer, i
    if total.prime? 
      row << total.to_s + "*"
    else
      row << total.to_s 
    end
  end
  puts "layer #{layer} - #{row.join(", ")}"
end

$colour_table = []
n = 0
(0 ... $n_layers).each do |layer|
  $colour_table[layer] = []
  (0 .. layer / 2).each do |i|
    $colour_table[layer][i] = n
    total = total_tiles layer, i
    if layer == 0 || total.prime? 
      n = (n + 1) % $layer_names.length
    end
  end
end

def snowflake svg, layer_name, centre
  if layer_name == $layer_names[$colour_table[0][0]]
    svg.circle centre, $radius, 
      style: "fill: none; stroke: #{layer_name}; stroke-width: 0.7"
  end
  (0 ... 360).step(60).each do |angle|
    right_up = [2 * $spacing * Math.cos(rad(angle + 30)), 
                2 * $spacing * Math.sin(rad(angle + 30))]
    down = [2 * $spacing * Math.cos(rad(angle + 150)), 
            2 * $spacing * Math.sin(rad(angle + 150))]
    top = centre
    (1 ... $n_layers).each do |layer|
      top = add(top, right_up)
      p = top
      (0 ... layer).each do |j|
        index = (layer / 2.0 - j).abs.to_i 
        if layer_name == $layer_names[$colour_table[layer][index]]
          svg.circle p, $radius, 
            style: "fill: none; stroke: #{layer_name}; stroke-width: 0.7"
        end
        p = add(p, down)
      end
    end
  end
end

output = "snowflake.svg"
puts "writing #{output} ..."
File.open output, "w" do |file|
  Svg.new file, viewBox: "0 0 1024 707" do |svg|
    $layer_names.each do |name|
      svg.layer name do 
        snowflake svg, name, [512, 353]
      end
    end
  end
end

