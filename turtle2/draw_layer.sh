#!/bin/bash

layer=$1

axicli drawing.svg \
  --model 2 --pen_pos_down 30 --pen_pos_up 70 \
  --speed_pendown 15 \
  --mode layers --layer $layer
