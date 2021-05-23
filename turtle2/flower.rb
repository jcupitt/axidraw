#!/usr/bin/ruby

require_relative "turtle"

Turtle.new "drawing.svg" do 

  50.times do
    move_to Random.rand(@width), Random.rand(@height)
    flower
  end

end
