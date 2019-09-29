#!/usr/bin/ruby

require_relative 'svg'

def midpoint(*points)
  points.transpose.map{|x| x.sum.to_f / points.length}
end

def sierpinski(svg, level, a, b, c)
  if level == 0
    svg.polygon [a, b, c], style: "fill: none; stroke: black; stroke-width: 1"
  else
    sierpinski svg, level - 1, a, midpoint(a, b), midpoint(a, c)
    sierpinski svg, level - 1, b, midpoint(b, a), midpoint(b, c)
    sierpinski svg, level - 1, c, midpoint(c, a), midpoint(c, b)
  end
end

puts "writing sierpinski.svg ..."
File.open "sierpinski.svg", "w" do |file|
  Svg.new file, viewBox: "0 0 1024 707" do |svg|
    sierpinski svg, 7, [0, 0], [1024, 0], [512, 707]
  end
end

