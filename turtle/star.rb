#!/usr/bin/env ruby

require_relative "turtle"

Turtle.new "drawing.svg" do |turtle|
  turtle.forward 300
  turtle.left 170
  turtle.pen_down

  36.times do
    turtle.forward 600
    turtle.left 170
  end
end
