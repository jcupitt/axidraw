#!/usr/bin/ruby

require_relative 'svg'

def midpoint(*points)
  points.transpose.map{|x| x.sum.to_f / points.length}
end

def length(v)
  Math.sqrt(v.map{|x| x ** 2}.sum)
end

def sub(a, b)
  a.zip(b).map{|(x, y)| x - y}
end

# find the largest circle we can fit within a triangle
def largest_circle(a, b, c)
  centre = midpoint(a, b, c)

  # the radius is the smallest distance to one of the edges
  dab = length(sub(centre, midpoint(a, b)))
  dac = length(sub(centre, midpoint(a, c)))
  dbc = length(sub(centre, midpoint(b, c)))

  [dab, dac, dbc].min
end

def circles(svg, offset, a, b, c)
  centre = midpoint(a, b, c)
  mab = midpoint(a, b)
  mbc = midpoint(b, c)
  mca = midpoint(c, a)
  r = largest_circle(mab, mbc, mca)

  # and we move in by the offset
  r -= offset

  svg.circle centre, r, style: "fill: none; stroke: black; stroke-width: 1"

  if r > 1
    circles svg, offset, a, midpoint(a, b), midpoint(a, c)
    circles svg, offset, b, midpoint(b, a), midpoint(b, c)
    circles svg, offset, c, midpoint(c, a), midpoint(c, b)
  end
end

puts "writing circles.svg ..."
File.open "circles.svg", "w" do |file|
  Svg.new file, viewBox: "0 0 1024 707" do |svg|
    height = 707
    width = height / Math.cos(Math::PI / 6)
    a = [512 - width / 2, 0]
    b = [512 + width / 2, 0]
    c = [512, height]
    mab = midpoint(a, b)
    mbc = midpoint(b, c)
    mca = midpoint(c, a)
    max_r = largest_circle(mab, mbc, mca)

    (0 .. max_r - 1).each do |offset|
      svg.layer "layer-#{offset}" do 
        circles svg, offset, a, b, c
      end
    end
  end
end

