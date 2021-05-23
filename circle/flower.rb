#!/usr/bin/ruby

require_relative "turtle"

Turtle.new "drawing.svg" do 
  # size is the petal length
  # angle is the arc radius we want the petal to fit within, so 36 for a petal
  # that fills 1/10th of a circle
  def petal size, angle
    n_petals = 360.0 / angle
    tip_length = 0.98 * 2.0 * size * Math::PI / n_petals
    step = angle / 6.0
    small = tip_length / 6.0
    ssmall = small / 2

    drawing do 
      forward 0.1 * size
      pen_down
      curve 0.9 * size, 90 + step, small
      curve small, 90 + step, small
      turn
      curve ssmall, 90 + step, small
      curve small, 90 + step, ssmall
      turn 
      curve small, 90 + step, small
      curve small, 90 + step, 0.9 * size
    end
  end

  def flower
    # posca pen colours
    colours = %w(green blue purple pink red yellow)
    our_colours = colours.shuffle[0 .. 3]
    n_petals = 5 + Random.rand(10)
    angle = 360.0 / n_petals
    size = 50 + Random.rand(100)

    drawing do
      n_petals.times do 
        left angle
        colour our_colours[0]
        petal size, angle
        colour our_colours[1]
        petal 0.9 * size, angle
        colour our_colours[2]
        petal 0.6 * size, angle
      end

      forward 10
      left 270
      colour our_colours[3]
      pen_down
      disc 10
    end
  end

  50.times do
    move_to Random.rand(@width), Random.rand(@height)
    flower
  end

end
