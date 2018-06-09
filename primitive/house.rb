#!/usr/bin/env ruby

require 'vips'

image = Vips::Image.new_from_file ARGV[0]
