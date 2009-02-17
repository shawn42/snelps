#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}"

require 'rubygems'
require 'rubygame'
include Rubygame

require "editor_environment"
require 'metaclass'
require 'publisher'
require 'constructor'
require 'diy'
require 'linked_list'

require 'resource_manager'
require 'input_manager'
require 'mouse_manager'
require 'sound_manager'
require 'network_manager'
require 'turn_manager'
require 'game_client'
require 'viewport'
require 'colors'
include Colors

class EditorApp

  def initialize()
    @context = DIY::Context.from_file(APP_ROOT + '/src/editor/editor_objects.yml')
  end
  
  def setup()
    Rubygame.init
    @client = @context[:game_client]
  end
  
  def main_loop()
    @input_manager = @context[:input_manager] 
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

console = false

if ARGV[0] == 'console'
  console = true
end

if $0 == __FILE__
  app = EditorApp.new
  if console
    require 'drb'
    DRb.start_service("druby://:7777", app)
  end
  app.run
end
