#!/usr/bin/env ruby

require_relative 'svg'

class Turtle
  def initialize filename
    @width = 1024
    @height = 707
    @file = File.open filename, "w" 
    @x = @width / 2
    @y = @height / 2
    @angle = 0
    @colour = "black"
    @all_colours = {}
    @pen_down = false
    @lines = []

    yield self

    puts "generating #{filename} ..."
    Svg.new @file, viewBox: "0 0 #{@width} #{@height}" do |svg|
      @all_colours.each_key do |layer_colour|
        svg.layer layer_colour do 
          @lines.each do |line_colour, x1, y1, x2, y2|
            if line_colour == layer_colour
              svg.line [x1, y1], [x2, y2], 
                    style: "stroke: #{line_colour}; stroke-width: 0.7"
            end
          end
        end
      end
    end
  end

  def rad(angle)
    2 * Math::PI * angle / 360.0
  end

  def forward(distance)
    new_x = @x + distance * Math.cos(rad(@angle))
    new_y = @y + distance * Math.sin(rad(@angle))
    if @pen_down
      @lines << [@colour, @x, @y, new_x, new_y]
      @all_colours[@colour] = true
    end
    @x = new_x
    @y = new_y
  end

  def left(angle)
    @angle += angle
  end

  def right(angle)
    @angle -= angle
  end

  def pen_up
    @pen_down = false
  end

  def pen_down
    @pen_down = true
  end

  def colour(colour)
    @colour = colour
  end

end
