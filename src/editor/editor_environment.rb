$: << "#{File.dirname(__FILE__)}/../../config"
require 'environment'
#require 'zenoptimize'
ED_ADDITIONAL_LOAD_PATHS = []
ED_ADDITIONAL_LOAD_PATHS.concat %w(
  src/editor
).map { |dir| File.dirname(__FILE__) + "/../" + dir }.select { |dir| File.directory?(dir) }

ED_ADDITIONAL_LOAD_PATHS.each do |path|
	$:.push path
end
