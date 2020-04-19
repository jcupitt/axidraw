#!/usr/bin/env ruby

require_relative "turtle"

Turtle.new "drawing.svg" do |turtle|
  20.times do
    turtle.drawing do
      turtle.pen_down
      size = 80
      face = 1
      20.times do
        turtle.forward size
        if face == 1
          turtle.circle_left size * 0.5
        else
          turtle.circle_right size * 0.5
        end
        turtle.left 10
        size *= 0.8
        face *= -1
      end
    end

    turtle.left 18
  end
end
