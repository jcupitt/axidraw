#!/usr/bin/env ruby

require 'vips'

# get the files from the same directory as us
$: << File.dirname(__FILE__) 

require 'svg'

image = Vips::Image.new_from_file ARGV[0]
edges = image.canny * 10
lch = edges.colourspace "lch"

$temp_number = 1

def primitive image
    image.write_to_file "x.png"
    svg_name = "layer-#{$temp_number}.svg"
    $temp_number += 1
    puts "generating #{svg_name} ..."
    if ! `primitive -i x.png -m 6 -n 100 -o #{svg_name}`
        exit
    end

    return svg_name
end

edge = (lch[0] > 0.05) & (lch[1] > 5) 

# pull out red / yellow pixels 25 - 80 hue
red = edge & (lch[2] > 25) & (lch[2] < 80)

# pull out greenish pixels 25 - 80 hue
green = edge & (lch[2] > 80) & (lch[2] < 130)

# pull out strong edges
black = (lch[0] > 30) ^ (red | green)

red_name = primitive red
green_name = primitive green
black_name = primitive black

thresh = 50

puts "writing x.svg ..."
File.open "x.svg", "w" do |s|
    Svg.new s, viewBox: "0 0 1024 656" do |svg|
        [red_name, green_name, black_name].each do |filename|
            svg.layer filename, 
                transform: "scale(4.000000) translate(0.5 0.5)" do |svg|
                File.foreach(filename).with_index do |line, line_num|
                    if line =~ /stroke="#([0-9a-f]+)"/
                        hex = $~[1]
                        if hex =~ /(..)(..)(..)/
                            if $~[2].hex < thresh
                                svg.svgtxt line.gsub hex, "000000"
                            end
                        end
                    end
                end
            end
        end
    end
end

