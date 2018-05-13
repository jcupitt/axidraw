#!/usr/bin/env python

import sys
import random
import math

import pyvips

# number of segments ...  12 is a clock face, for example
angles = 60

image = pyvips.Image.new_from_file(sys.argv[1])

if image.width != image.height:
    print "image must be square"
    sys.exit(1)

# mask to a circle
mask = pyvips.Image.black(image.width, image.height)
mask = mask.draw_circle(255, 
                        image.width / 2, image.height / 2, image.width / 2,
                        fill=True)
image = mask.ifthenelse(image, 0)

vectors = []
for angle in range(0, 180, 360 / angles):
    columns, rows = image.rotate(angle).project()
    vectors.append(rows)

length = 0
max_value = 0
for image in vectors:
    if image.height > length:
        length = image.height
    if image.max() > max_value:
            max_value = image.max()

bg = pyvips.Image.black(length, length)
for i in range(len(vectors)):
    x = vectors[i]
    strips = x.zoom(x.height, 1).rotate(i * 360 / angles)
    bg += strips.gravity('centre', length, length)

# bg.write_to_file("x.v")

def line(x1, y1, x2, y2):
    print '      <line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}"/>' \
          .format(x1=x1, y1=y1, x2=x2, y2=y2)

print '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000">'
  <g transform="translate(500, 500)" style="stroke:rgb(0,0,0);stroke-width:1">\
'''
for i in range(len(vectors)):
    angle = i * -360 / angles
    x = vectors[i]

    print '    <g transform="rotate({angle})">'.format(angle=angle)

    for j in range(x.height):
        pixel = x(0, j)[0]
        prob = float(pixel) / max_value
        ln = j - x.height / 2
        y = ln * 400 / (image.height / 2)

        if 3 * random.random() < prob:
            line(-400, y, 400, y)

    print '    </g>'

print '  </g>'
print '</svg>'


