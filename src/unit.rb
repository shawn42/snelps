#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"

class Unit
	include Sprites::Sprite

  def initialize(*args = {})
    @animation_manager = args[:animation_manager]
    @sound_manager = args[:sound_manager]
    @viewport = args[:viewport]
    @unit_type = args[:unit_type]
    x = args[:x]
    y = args[:y]

    @animation_manager.register(self)
    @image = @animation_manager.get_default_frame(@unit_type)

		@rect = Rect.new(x,y,*@image.size)
  end

  def update(time)
#    @animation_manager.update(self, time)
  end

  def draw(destination)
    x,y = @rect.center 
    x,y = @viewport.world_to_view(x+(w-@image.w)/2, y+(h-@image.h)/2)
    @image.blit(destination, [x,y,@image.w,@image.h])
  end

  def centerx();@rect.centerx;end
  def centery();@rect.centery;end

end
