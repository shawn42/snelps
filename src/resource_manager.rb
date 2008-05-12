#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "fileutils"
require 'map_script'

class ResourceManager
  
  def initialize()
    @loaded_images = {}
  end
  
  def load_map(map_name)
    map = YAML::load_file(MAP_PATH + map_name + ".yml")
    map.script = MapScript.new(File.open(MAP_PATH + map_name + ".rb").readlines.join("\n"))
    map.resource_manager = self
    map.script.map = map
    map
  end

  def save_map(map, file_name)
    File.open MAP_PATH + file_name + ".yml", "w" do |f|
      YAML::dump(map, f)
    end
  end

  def load_image(file_name, entity_type = :unit_worker)
    @loaded_images[entity_type] ||= {}
    ent_images = @loaded_images[entity_type]
    if ent_images[file_name].nil?
      image = nil
      begin
        image = Rubygame::Surface.load_image(File.expand_path(DATA_PATH + "gfx/" + file_name))
      rescue Exception => ex
        image = Rubygame::Surface.load_image(File.expand_path(GDATA_PATH + "gfx/" + file_name))
      end
      ent_images[file_name] = image
    else
      ent_images[file_name]
    end
  end

  def load_music(name)
    begin
      full_name = File.expand_path(DATA_PATH + "sound/" + name)
      sound = Rubygame::Mixer::Music.load_audio(full_name)
      return sound
    rescue Rubygame::SDLError => ex
      puts "Cannot load sound " + full_name + " : " + ex
      exit
    end
  end

  def load_sound(name)
    begin
      full_name = File.expand_path(DATA_PATH + "sound/" + name)
      sound = Rubygame::Mixer::Sample.load_audio(full_name)
      return sound
    rescue Rubygame::SDLError => ex
      puts "Cannot load sound " + full_name + " : " + ex
      exit
    end
  end

  def load_ttf_font(name, size)
    TTF.new(DATA_PATH + "fonts/" + name, size)
  end

  def load_config(name)
    conf = YAML::load_file(CONFIG_PATH + name + ".yml")
    user_file = "#{ENV['HOME']}/.snelps/#{name}.yml"
    if File.exist? user_file
      user_conf = YAML::load_file user_file
      conf = conf.merge user_conf
    end
    conf
  end

  def save_settings(name, settings)
    user_snelps_dir = "#{ENV['HOME']}/.snelps"
    FileUtils.mkdir_p user_snelps_dir
    user_file = "#{ENV['HOME']}/.snelps/#{name}.yml"
    File.open user_file, "w" do |f|
      f.write settings.to_yaml
    end
  end

  def load_entity_config(name)
    YAML::load_file(ENTITY_DATA_PATH + name + ".yml")
  end

  def load_campaign(campaign_name)
    YAML::load_file(CAMPAIGN_PATH + campaign_name + ".yml")
  end
  
end
