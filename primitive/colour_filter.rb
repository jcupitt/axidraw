#!/usr/bin/env ruby

# get the files from the same directory as us
$: << File.dirname(__FILE__) 

require 'svg'

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
