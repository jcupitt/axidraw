#!/usr/bin/env ruby

require_relative "turtle"

$colours = %w(green blue purple pink red yellow)

def stem turtle, handedness, size, factor
  turtle.drawing do
    turtle.pen_down
    turtle.forward size * 0.5

    i = 0
    face = handedness

    while size > 0.5 do
      turtle.left 5 * handedness

      if i % 4 == 1
        turtle.drawing do
          turtle.right 60 * handedness
          turtle.forward size * 0.6
          stem turtle, handedness * -1, size, factor * 0.88
        end
        turtle.left 10 * handedness
      else
        turtle.drawing do
          turtle.left 90 * face
          turtle.forward size * 0.2
          turtle.left 90 
          turtle.colour $colours.sample 
          turtle.disc size * 0.7
        end
      end

      turtle.left 5 * handedness
      turtle.forward size

      i += 1
      size *= factor
      face *= -1
    end
  end
end

Turtle.new "drawing.svg" do |turtle|
  turtle.right 37

  centre_circle_radius = 33

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
      stem turtle, 1, 46, 0.95
    end
    turtle.left 180
  end
end
