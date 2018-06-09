#!/bin/bash

primitive -i house_black.png -m 6 -n 1000 -o x.svg
./colour_filter.rb x.svg 230 > house_black.svg

primitive -i house_red.png -m 6 -n 100 -o x.svg
./colour_filter.rb x.svg 230 > house_red.svg

primitive -i house_green.png -m 6 -n 100 -o x.svg
./colour_filter.rb x.svg 230 > house_green.svg

primitive -i house_yellow.png -m 6 -n 100 -o x.svg
./colour_filter.rb x.svg 230 > house_yellow.svg

primitive -i house_blue.png -m 6 -n 100 -o x.svg
./colour_filter.rb x.svg 230 > house_blue.svg

rm x.svg
