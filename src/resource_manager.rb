#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"

class ResourceManager
  def initialize()
    @loaded_images = {}
  end
  def load_map(map_name)
    YAML::load_file(MAP_PATH + map_name + ".yml")
  end
  def save_map(map, file_name)
    File.open MAP_PATH + file_name + ".yml", "w" do |f|
      YAML::dump(map, f)
    end
  end

  def load_image(file_name, colorkey = nil)
    if @loaded_images[file_name].nil?
      image = Rubygame::Surface.load_image(File.expand_path(DATA_PATH + "gfx/" + file_name))
      if colorkey != nil
        if colorkey == -1
          colorkey = image.get_at([0,0])
        end
        image.set_colorkey(colorkey)
      end
      @loaded_images[file_name] = image
    else
      @loaded_images[file_name]
    end
  end
end
