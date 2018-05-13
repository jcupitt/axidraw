#!/usr/bin/env ruby

require 'optparse'
require 'vips'

# get the files from the same directory as us
$: << File.dirname(__FILE__) 

require 'svg'

$options = {
	:verbose => true,
	:fatal => false,
	:output => "x.svg",
}
OptionParser.new do |opts|
	opts.banner = "Usage: #{$0} [options] input-image"

	opts.on("-o", "--output=FILE", "output to FILE") do |file|
		$options[:output] = file
	end
	opts.on("-f", "--fatal", "Stop on first error") do |v|
		$options[:fatal] = v
	end
	opts.on("-q", "--quiet", "Run quietly") do |v|
		$options[:verbose] = false
	end
end.parse!

def log(msg)
	if $options[:verbose]
		puts msg
	end
end

def err(msg)
	puts msg

	if $options[:fatal]
		exit
	end
end

# number of segments ...  12 is a clock face, for example
ANGLES = 120

log "loading #{ARGV[0]} ..." 
image = Vips::Image.new_from_file ARGV[0]
image = image.invert()

if image.width != image.height
    err "image must be square"
end
diameter = image.width 
radius = diameter / 2

# mask to a circle
log "generating vectors ..."
mask = Vips::Image.black image.width, image.height
mask = mask.draw_circle 255, radius, radius, radius, fill: true
image = mask.ifthenelse image, 0 

vectors = []
(0 ... ANGLES / 2).each do |i|
    angle = -i * 360 / ANGLES
    columns, rows = image.rotate(angle).project()
    vectors << rows
end

length = 0
max_value = 0
vectors.each do |image|
    length = [length, image.height].max
    max_value = [max_value, image.max()].max
end

bg = Vips::Image.black length, length 
vectors.each_with_index do |image, i|
    strips = image.zoom(image.height, 1).rotate(i * 360 / ANGLES)
    bg += strips.gravity('centre', length, length)
end

# log "writing simulated output ..."
# bg.write_to_file "x.v"

# make the image vectors into simple Ruby arrays
arrays = vectors.map {|vector| vector.to_a.transpose[0].transpose[0]}

log "writing SVG to #{$options[:output]} ..."
File.open $options[:output], "w" do |s|
    Svg.new s, viewBox: "0 0 1000 1000" do |svg|
        svg.g transform: "translate(500, 500)", 
            style: "stroke: black; stroke-width: 1" do |svg|
            arrays.each_with_index do |array, i|
                svg.g transform: "rotate(#{i * -360 / ANGLES})" do |svg|
                    (0 ... array.length).each do |j|
                        prob = array[j] / max_value
                        ln = j - array.length / 2
                        y = ln * 400 / (array.length / 2)

                        svg.line(-400, y, 400, y) if 4 * rand < prob
                    end
                end
            end
        end
    end
end
