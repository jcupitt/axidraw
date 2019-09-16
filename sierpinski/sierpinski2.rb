#!/usr/bin/ruby

require_relative 'svg'

def midpoint((x1, y1), (x2, y2))
  [(x1 + x2) / 2, (y1 + y2) / 2]
end

def move(p)
  "M#{p[0]},#{p[1]}"
end

def line(p)
  "L#{p[0]},#{p[1]}"
end

def sierpinski(level, a, b, c)
  mab = midpoint a, b
  mbc = midpoint b, c
  mac = midpoint a, c
  result = ""

  if level == 0
    result += line(mac) + line(mbc) + line(mab)
  else
    mabac = midpoint mab, mac 
    macbc = midpoint mac, mbc 
    mbcab = midpoint mbc, mab 

    result += line(mabac) + sierpinski(level - 1, mab, mac, a) + line(mac)
    result += line(macbc) + sierpinski(level - 1, mac, mbc, c) + line(mbc)
    result += line(mbcab) + sierpinski(level - 1, mbc, mab, b) + line(mab)
  end

  result
end

puts "writing sierpinski.svg ..."
File.open "sierpinski.svg", "w" do |file|
  Svg.new file, viewBox: "0 0 1024 707" do |svg|
    a = [0.0, 0.0]
    b = [1024.0, 0.0]
    c = [512.0, 707.0]
    svg.path move(midpoint(a, b)) + sierpinski(6, a, b, c), 
      style: "stroke: black; stroke-width: 1"
  end
end

