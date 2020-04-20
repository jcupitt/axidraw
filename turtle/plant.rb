#!/usr/bin/env ruby

require_relative "turtle"

def stem turtle, handedness, size, factor
  turtle.drawing do
    turtle.pen_down
    i = 1
    face = handedness
    while size > 1 do
      turtle.forward size

      turtle.left 5 * handedness

      if i % 5 == 3
        turtle.drawing do
          turtle.right 60 * handedness
          stem turtle, handedness, size, factor * 0.94
        end
      else
        turtle.circle size * 0.5 * face
      end

      turtle.left 5 * handedness

      i += 1
      size *= factor
      face *= -1
    end
  end
end

Turtle.new "drawing.svg" do |turtle|
  turtle.right 45
  2.times do
    stem turtle, 1, 43, 0.95
    turtle.left 180
  end
end
