#!/usr/bin/env python

import sys
import math

import pyvips

# number of lines we discover
n_lines = 10000

image = pyvips.Image.new_from_file(sys.argv[1])

print "analyzing ..."
hough = image.hough_line(width=256, height=256)

# use rank() to find pixels which are equal to their local maximum
# and are not tiny 
local_max = (hough.rank(5, 5, 24) == hough) & (hough > 10)

# difference from local blur finds "peakyness"
peaky = (hough - hough.gaussblur(2)) > 1

# mask out boring bits
points = (local_max & peaky).ifthenelse(hough, 0)

points.write_to_file("points.v")

mx, opts = points.max(size=n_lines, x_array=True, y_array=True)
coordinates = zip(opts["x_array"], opts["y_array"])

print "drawing lines ..."
out = pyvips.Image.black(image.width, image.height)
for x, y in coordinates:
    print "x =", x
    print "y =", y

    angle = math.pi * x / hough.width
    distance = image.height * y / hough.height

    print "angle =", angle
    print "distance =", distance
    
    cx = distance * math.cos(angle)
    cy = distance * math.sin(angle)

    print "cx =", cx
    print "cy =", cy

    vx = image.width * 2 * math.cos(angle + math.pi)
    vy = image.width * 2 * math.sin(angle + math.pi)

    print "vx =", vx
    print "vy =", vy

    x1 = cx + vx
    y1 = cy + vy
    x2 = cx - vx
    y2 = cy - vy

    out = out.draw_line(255, x1, y1, x2, y2)

out.write_to_file("lines.v")






