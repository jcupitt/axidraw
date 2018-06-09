#!/usr/bin/env ruby

thresh = ARGV[1].to_i

File.foreach(ARGV[0]).with_index do |line, line_num|
    if line =~ /stroke="#([0-9a-f]+)"/
        hex = $~[1]
        if hex =~ /(..)(..)(..)/
            if $~[2].hex < thresh
                puts line.gsub hex, "000000"
            end
        end
    else
        puts line if line !~ /rect/
    end
end
