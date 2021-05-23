#!/bin/bash

layer=$1

axicli drawing.svg \
  --pen_pos_down 0 --pen_pos_up 90 --speed_pendown 15 --model 2 \
  --mode layers --layer $layer
