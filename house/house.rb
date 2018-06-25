#!/usr/bin/env ruby

require 'vips'

# get the files from the same directory as us
$: << File.dirname(__FILE__) 

require 'svg'

image = Vips::Image.new_from_file ARGV[0]
lch = image.colourspace "lch"
edges = lch[0].canny * 10
hue = lch[2]
chroma = lch[1].gaussblur(10)

$temp_number = 1

def primitive image
    (image * -1 + 255).write_to_file "x.png"
    svg_name = "layer-#{$temp_number}.svg"
    $temp_number += 1
    puts "generating #{svg_name} ..."
    if ! `primitive -i x.png -m 6 -n 1000 -o #{svg_name}`
        exit
    end
    File.delete("x.png")

    return svg_name
end

# pull out strong edges
black = (edges > 10) 
# black.write_to_file "black.png"

# pull out red / yellow pixels 25 - 80 hue
red = (edges > 6) & (hue > 25) & (hue < 80) & (chroma > 5) & !black
# red.write_to_file "red.png"

# pull out greenish pixels 80 - 130 hue
green = (edges > 6) & (hue > 80) & (hue < 130) & (chroma > 5) & !black
# green.write_to_file "green.png"

# pull out other pixels >130 
blue = (edges > 6) & (hue > 130)  & !black
# blue.write_to_file "blue.png"

red_name = primitive red
green_name = primitive green
black_name = primitive black
blue_name = primitive blue

thresh = 220

puts "writing x.svg ..."
File.open "x.svg", "w" do |s|
    Svg.new s, viewBox: "0 0 1024 656" do |svg|
        [red_name, green_name, blue_name, black_name].each do |filename|
            svg.layer filename, 
                transform: "scale(4.000000)" do |svg|
                File.foreach(filename).with_index do |line, line_num|
                    if line =~ /stroke="#([0-9a-f]+)"/
                        hx = $~[1]
                        if hx =~ /(..)(..)(..)/
                            if $~[2].hex < thresh
                                svg.svgtxt line
                            end
                        end
                    end
                end
            end
        end
    end
end

File.delete(red_name)
File.delete(green_name)
File.delete(black_name)
File.delete(blue_name)
