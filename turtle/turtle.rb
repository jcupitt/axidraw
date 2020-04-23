#!/usr/bin/env ruby

require_relative 'svg'

# A simple turtle graphics class. This uses the SVG class to generate a drawing
# which can be sent to an axidraw or viewed in a web browser.
#
# In atom, use an SVG preview plugin to watch the SVG while you edit!

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
    @circles = []
    @discs = []

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

          @circles.each do |circle_colour, cx, cy, radius|
            if circle_colour == layer_colour
              svg.circle [cx, cy], radius,
                    style: "stroke: #{circle_colour}; stroke-width: 0.7"
            end
          end

          @discs.each do |disc_colour, cx, cy, radius|
            if disc_colour == layer_colour
              svg.disc [cx, cy], radius,
                    style: "stroke: #{disc_colour}; stroke-width: 0.7"
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

  # An open circle to the left of the turtle. Use a negative radius to
  # draw the circle on the right.
  def circle radius
    if @pen_down
      cx = @x + radius * Math.cos(rad(@angle - 90))
      cy = @y + radius * Math.sin(rad(@angle - 90))
      @circles << [@colour, cx, cy, radius.abs]
      @all_colours[@colour] = true
    end
  end

  def circle_left radius
    circle radius
  end

  def circle_right radius
    circle -radius
  end

  # A solid disc sitting to the left of the turtle. Use a negative radius to
  # draw the disc on the right.
  def disc radius
    if @pen_down
      cx = @x + radius * Math.cos(rad(@angle - 90))
      cy = @y + radius * Math.sin(rad(@angle - 90))
      @discs << [@colour, cx, cy, radius.abs]
      @all_colours[@colour] = true
    end
  end

  def disc_left radius
    disc radius
  end

  def disc_right radius
    disc -radius
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

  # This make a sub-drawing ... the turtle state is restored after this block
  # executes. You can nest these, which means you can draw fractals.
  def drawing
    save_x = @x
    save_y = @y
    save_angle = @angle
    save_colour = @colour
    save_pen_down = @pen_down

    yield self

    @x = save_x
    @y = save_y 
    @angle = save_angle 
    @colour = save_colour
    @pen_down = save_pen_down 
  end

end
