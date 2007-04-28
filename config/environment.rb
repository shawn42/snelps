require 'rubygems'
ADDITIONAL_LOAD_PATHS = []
ADDITIONAL_LOAD_PATHS.concat %w(
  src 
  lib 
  lib/ruby3d
  config 
).map { |dir| File.dirname(__FILE__) + "/../" + dir }.select { |dir| File.directory?(dir) }

ADDITIONAL_LOAD_PATHS.each do |path|
	$:.push path
end
DATA_PATH = File.dirname(__FILE__) + "/../data/"
