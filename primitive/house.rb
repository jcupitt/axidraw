#!/usr/bin/env ruby

require 'vips'

# get the files from the same directory as us
$: << File.dirname(__FILE__) 

require 'svg'

image = Vips::Image.new_from_file ARGV[0]

# enough detail for what we need
image = image.thumbnail 512

temp_number = 1
def primitive image
    image.write_to_file "x.png"
    svg_name = "layer-#{temp_number}.svg"
    puts "generating #{svg_name} ..."
    if ! `primitive -i x.png -m 6 -n 1000 -o #{svg_name}`
        exit
    end

    return svg_name
end

# to LCh, pull out reddish pixels 

kkkkkkk




thresh = ARGV[0].to_i


puts "writing x.svg ..."
File.open "x.svg", "w" do |s|
    Svg.new s, viewBox: "0 0 1000 1000" do |svg|
        ARGV.drop(1).each do |filename|
            svg.layer filename do |svg|
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

