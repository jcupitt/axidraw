#!/usr/bin/env ruby

require_relative "turtle"

Turtle.new "drawing.svg" do |turtle|
  turtle.forward 300
  turtle.left 175
  turtle.pen_down

  72.times do
    turtle.forward 600
    turtle.left 175
  end
end
