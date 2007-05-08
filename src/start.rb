#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"
require 'needle'
class SnelpsApp

  def initialize()
    @registry = Needle::Registry.define do |r|
      r.resource_manager { ResourceManager.new }
      r.animation_manager { AnimationManager.new(r.resource_manager) }
    end
  end

  def run()
  end
end


if $0 == __FILE__
  app = SnelpsApp.new
  app.run
end
