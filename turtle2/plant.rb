#!/usr/bin/env ruby

require_relative "turtle"

# posca pen colours
$colours = %w(green blue purple pink red yellow)

$centre_circle_radius = 33

Turtle.new "drawing.svg" do 
  # size is the petal length
  # angle is the arc radius we want the petal to fit within, so 36 for a petal
  # that fills 1/10th of a circle
  def petal radius, angle
    n_petals = 360.0 / angle
    tip_length = 0.98 * 2.0 * radius * Math::PI / n_petals
    step = angle / 6.0
    small = tip_length / 6.0
    ssmall = small / 2

    drawing do 
      forward 0.1 * radius
      pen_down
      curve 0.9 * radius, 90 + step, small
      curve small, 90 + step, small
      turn
      curve ssmall, 90 + step, small
      curve small, 90 + step, ssmall
      turn 
      curve small, 90 + step, small
      curve small, 90 + step, 0.9 * radius
    end
  end

  def flower radius
    our_colours = $colours.shuffle[0 .. 3]
    n_petals = 5 + Random.rand(10)
    angle = 360.0 / n_petals

    drawing do
      n_petals.times do 
        left angle
        if radius > 15
          colour our_colours[0]
          petal radius, angle
          petal radius - 2, angle
          petal radius - 4, angle
          colour our_colours[1]
          petal radius - 6, angle
          colour our_colours[2]
          petal radius - 8, angle
        else
          colour our_colours[0]
          petal radius, angle
        end
      end

      forward radius / 10.0
      left 270
      colour our_colours[3]
      pen_down
      disc radius / 10.0
    end
  end

  def stem handedness, size, factor
    drawing do
      pen_down
      forward size * 0.5

      i = 0
      face = handedness

      # while size > 0.5 do
      while size > 10 do
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
            forward size * 0.3
            colour $colours.sample 
            pen_up
            forward size * 0.7
            flower size * 0.7
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

  flower $centre_circle_radius 

  right 37

  2.times do
    drawing do
      forward $centre_circle_radius
      pen_down
      forward 10
      stem 1, 46, 0.95
    end
    turn
  end
end
