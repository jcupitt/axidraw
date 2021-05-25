#!/usr/bin/env ruby

require_relative "turtle"

# posca pen colours
$colours = %w(green blue purple pink red yellow)

$centre_circle_radius = 33

Turtle.new "drawing.svg" do 
  def petal_sides r, a
    ha = a / 2.0
    w = 2.0 * r * Math.sin(rad(ha))

    drawing do 
      left ha
      forward 0.1 * r

      pen_down
      curve 0.9 * r, 90.0 + ha, 0.2 * w

      pen_up
      forward 0.6 * w

      pen_down
      curve 0.2 * w, 90 + ha, 0.9 * r
    end
  end

  def petal_tip r, a, x1
    ha = a / 2.0
    w = 2.0 * r * Math.sin(rad(ha))
    adj = r * Math.cos(rad(ha))
    ma = deg(Math.atan(0.3 * w / adj))
    mr = adj / Math.cos(rad(ma))
    tl = 0.2 * mr * x1
    tw = 2.0 * (mr + tl) * Math.sin(rad(ma))

    drawing do 
      left ma
      forward mr
      pen_down
      curve tl, 90 + ma, tw / 2.0
      curve tw / 2.0,  90 + ma, tl
    end
  end

  def petal r, a, x1, x2, c1, c2, c3
    tip_length = 1 + 10 * x1
    liner_length = 1 + 10 * x2
    stripe_length = r * (0.3 + x1 * 0.3)

    if r < 5
      tip_length = 1
    end

    colour c1
    petal_sides r, a
    (0 ... tip_length).each do |i|
      petal_tip r - i, a, x1
    end

    if r > 15
      colour c2
      (0 ... liner_length).each do |i|
        petal_tip r - tip_length - i, a, x1
      end
    end

    drawing do
      forward r * 0.2
      colour c3
      pen_down
      forward stripe_length
    end
  end

  def flower r
    our_colours = $colours.shuffle[0 .. 3]
    c1 = our_colours[0]
    c2 = our_colours[1]
    c3 = our_colours[2]
    c4 = our_colours[3]
    x1 = Random.rand
    x2 = Random.rand
    n_petals = 5 + Random.rand(10)
    angle = 360.0 / n_petals

    drawing do
      n_petals.times do 
        left angle
        petal r, angle, x1, x2, c1, c2, c3
      end

      forward r / 10.0
      right 270
      colour c4
      pen_down
      disc r / 10.0
    end
  end

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
