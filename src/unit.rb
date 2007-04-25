#!/usr/bin/env ruby

require "#{File.dirname(__FILE__)}/../config/environment"
class Snelp
	include Sprites::Sprite
  IMAGE_LIST = ['unit1r.png','unit2r.png','unit3r.png','unit4r.png','unit4r.png','unit6r.png','unit7r.png']
  # TODO how to do this for all machines at the correct speed?
  FRAME_UPDATE_TIME = 100
  @@pics = []
  @@selected_image = Transform.zoom(Image.load(DATA_PATH + "/gfx/magiceffect0.png"),[0.2,0.2],true)
  IMAGE_LIST.each do |img|
    @@pics <<  Image.load(DATA_PATH + "/gfx/#{img}")
  end
	attr_accessor :vx, :vy, :speed, :frame, :animating, :selected
  def on_selection()
    @selected = true
  end
  def on_unselection()
    @selected = false
  end
  def order(pos)
    puts "GOTO #{pos.first},#{pos.last}"
    @animating = true
  end
	def initialize(x,y,rate=0.1)
		super()
    @pic = @@pics.first
    @animating = true
    @selected = false
    @pic.set_colorkey(@pic.get_at([0,0]))
		@rate = rate
		@vx, @vy = 0,0
		@speed = 40
		@image = @pic
		@delta = 0
		@frame = 1
    @time_since_last_frame_change = 0
		@rect = Rect.new(x,y,*@pic.size)
	end
  def update(time)
    x,y = @rect.center
    self.update_image(time)
    @rect.size = @image.size
    base = @speed * time/1000.0
    @rect.centerx = x + @vx * base
    @rect.centery = y + @vy * base
  end
  def animating?()
    @animating
  end
  def update_image(time)
    @pic = @@pics[@frame]
    if @time_since_last_frame_change > FRAME_UPDATE_TIME and animating?
      @frame = (@frame + 1) % IMAGE_LIST.size
      @time_since_last_frame_change = 0
      # blit in selection bubble
    else
      @time_since_last_frame_change += time
    end
    
    @pic = @@selected_image if @selected
    @image = @pic
  end
end
