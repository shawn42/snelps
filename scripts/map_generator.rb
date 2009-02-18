#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"
require 'rubygame'
include Rubygame
require 'map'

require 'resource_manager'

# TODO BUG!!  why do these have to be the same?  see Map.load_from_file
# 1920 x 1920 in px
num_rows = 60
num_cols = 60
tiles = NArray.int(num_rows,num_cols)
num_rows.times do |i|
  num_cols.times do |j|
    tiles[i,j] = 1#rand(8+1)
  end
end

#10.times do |i|
#  10.times do |j|
#    tiles[20+i,20+j] = 266
#  end
#end

map = Map.new 
map.resource_manager = ResourceManager.new
map.tiles = tiles 
map.width = num_cols
map.height = num_rows
map.tile_size = 32
map.half_tile_size = 16
#map.load_images
map.save ARGV[0]

