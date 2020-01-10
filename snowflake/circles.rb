#!/usr/bin/env ruby

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

def add(a, b)
  a.zip(b).map{|(x, y)| x + y}
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

def circles(svg, offset, t, a, b, c)
  centre = midpoint(a, b, c)
  mab = midpoint(a, b)
  mbc = midpoint(b, c)
  mca = midpoint(c, a)
  r = largest_circle(mab, mbc, mca)

  # and we move in by the offset
  r -= offset

  # smaller than this and pens stop working well, since almost all circles
  # are too small for a ballpoint to make enough ink flow
  if r > 0.5
    svg.circle_thick centre, r, t, 
      style: "fill: none; stroke: black; stroke-width: 0.7"

    circles svg, offset, t, a, midpoint(a, b), midpoint(a, c)
    circles svg, offset, t, b, midpoint(b, a), midpoint(b, c)
    circles svg, offset, t, c, midpoint(c, a), midpoint(c, b)
  end
end

# a random number between 0 and 1 with gaussian distribution .. just sum 10
# rands
def gnoise
  (1..10).map{rand}.reduce(:+) / 10
end

layer_names = %w[red green blue yellow black purple orange violet polkadot cyan cerise]

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

    # we assign each line to a layer ... pick the nearest, but with a gaussian
    # noise fuzz to smooth out transitions
    name_of_radius = {}
    (0 .. max_r).each do |x|
      fuzz_x = x / max_r + (gnoise - 0.5) / 3.0
      fuzz_x = [[0.0, fuzz_x].max, 0.99].min
      name_of_radius[x] = layer_names[(fuzz_x * layer_names.length).to_i]
    end

    # now find neighbouring circles which have been assigned the same colour
    thickness_of_radius = {}
    (0 .. max_r).each do |x|
      r = 1
      while x + r <= max_r && name_of_radius[x] == name_of_radius[x + r]
        r += 1
      end
      thickness_of_radius[x] = r 
    end

    layer_names.each do |name|
      svg.layer name do 
        offset = 0
        while offset <= max_r
          t = thickness_of_radius[offset]
          if name_of_radius[offset] == name
            circles svg, offset, t - 1, a, b, c
          end
          offset += t
        end
      end
    end
  end
end

