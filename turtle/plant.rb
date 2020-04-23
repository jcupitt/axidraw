#!/usr/bin/env ruby

require_relative "turtle"

class Turtle
  # posca pen colours
  @@colours = %w(green blue purple pink red yellow)

  def stem handedness, size, factor
    drawing do
      pen_down
      forward size * 0.5

      i = 0
      face = handedness

      while size > 0.5 do
        left 5 * handedness

        if i % 4 == 1
          drawing do
            right 60 * handedness
            forward size * 0.6
            stem handedness * -1, size, factor * 0.88
          end
          left 10 * handedness
        else
          drawing do
            left 90 * face
            forward size * 0.2
            left 90 
            colour @@colours.sample 
            disc size * 0.7
          end
        end

        left 5 * handedness
        forward size

        i += 1
        size *= factor
        face *= -1
      end
    end
  end
end

centre_circle_radius = 33

Turtle.new "drawing.svg" do |turtle|
  turtle.right 37

  turtle.drawing do
    turtle.forward centre_circle_radius
    turtle.left 270
    turtle.pen_down
    turtle.circle centre_circle_radius 
  end

  2.times do
    turtle.drawing do
      turtle.forward centre_circle_radius
      turtle.pen_down
      turtle.forward 10
      turtle.stem 1, 46, 0.95
    end
    turtle.left 180
  end
end
