#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"
require 'needle'

require 'animation_manager'
require 'input_manager'
require 'resource_manager'
require 'sound_manager'
require 'game_client'
require 'viewport'
require 'rubygame'
include Rubygame

class SnelpsApp

  def initialize()
    @registry = Needle::Registry.define do |r|
      r.game_client { GameClient.new r.resource_manager, r.sound_manager, r.input_manager, r.animation_manager, r.viewport }
      r.viewport { Viewport.new r.screen }
      r.screen { Screen.set_mode [400, 300] }
      r.resource_manager { ResourceManager.new }
      r.sound_manager { SoundManager.new }
      r.input_manager { InputManager.new }
      r.animation_manager { AnimationManager.new(r.resource_manager) }
    end
  end
  
  def setup()
    # create game server (for now)
    Rubygame.init
    @client = @registry[:game_client]
  end
  
  def main_loop()
    @input_manager = @registry[:input_manager] 
    @input_manager.main_loop @client
  end

  def shutdown()
    Rubygame.quit
  end

  def run()
    setup

    main_loop

    shutdown
  end
end


if $0 == __FILE__
  app = SnelpsApp.new
  app.run
end
