require 'rubygems'
#require 'zenoptimize'
ADDITIONAL_LOAD_PATHS = []
ADDITIONAL_LOAD_PATHS.concat %w(
  src 
  src/components
  src/gui
  lib 
  lib/ruby3d
  config 
).map { |dir| File.dirname(__FILE__) + "/../" + dir }.select { |dir| File.directory?(dir) }

ADDITIONAL_LOAD_PATHS.each do |path|
	$:.push path
end
# WHY DO I NEED THIS TO RUN ruby -w
$:.push "/usr/local/lib/ruby/site_ruby/1.8/i686-darwin8.10.1"
APP_ROOT = File.dirname(__FILE__) + "/../"
DATA_PATH =  APP_ROOT + "data/"
ENTITY_DATA_PATH =  DATA_PATH + "gameplay/"
MAP_PATH = APP_ROOT + "maps/"
CONFIG_PATH = APP_ROOT + "config/"
GFX_PATH = DATA_PATH + "gfx/"
CAMPAIGN_PATH = DATA_PATH + "campaigns/"

