#!/usr/bin/env ruby

require 'vips'

# get the files from the same directory as us
$: << File.dirname(__FILE__) 

require 'svg'

image = Vips::Image.new_from_file ARGV[0]
lch = image.colourspace "lch"
lightness = lch[0]
edges = lightness.canny * 10
hue = lch[2]
chroma = lch[1].gaussblur(10)

edges.write_to_file "edges.v"
hue.write_to_file "hue.v"
chroma.write_to_file "chroma.v"

def primitive image, name
    (image * -1 + 255).write_to_file "x.png"
    svg_name = "#{name}.svg"
    puts "generating #{name} ..."
    if ! `primitive -i x.png -m 6 -n 1000 -o #{svg_name}`
        exit
    end
    File.delete("x.png")

    return svg_name
end

skin = (lightness > 40) & (lightness < 75) 
       (chroma > 10) & (chroma < 40) & 
       (hue > 25) & (hue < 80)  

hair = (lightness < 40) &
       (chroma > 10) & (chroma < 40) & 
       (hue > 25) & (hue < 80)  

other = !skin & !hair

black = edges > 8
gold = (edges > 6) & hair
bronze = (edges > 6) & skin
silver = (edges > 6) & other

black_name = primitive black, "1-black"
gold_name = primitive gold, "2-gold"
silver_name = primitive silver, "3-silver"
bronze_name = primitive bronze, "4-bronze"
layers = [black_name, gold_name, silver_name, bronze_name]

thresh = 220

puts "writing nieces.svg ..."
File.open "nieces.svg", "w" do |s|
    Svg.new s, viewBox: "0 0 1024 707" do |svg|
        layers.each do |filename|
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

layers.each {|filename| File.delete filename}
