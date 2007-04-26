#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"

class Snelp
	include Sprites::Sprite
  def load_image(name, colorkey=nil)
      # Rubygame::Image.load has been replaced with Surface
    image = Rubygame::Surface.load_image(File.expand_path(DATA_PATH + "gfx/" + name))
    if colorkey != nil
      if colorkey == -1
        colorkey = image.get_at([0,0])
      end
      image.set_colorkey(colorkey)
    end
    return image, Rubygame::Rect.new(0,0,*image.size)
  end
  def load_sound(name)
      return nil unless $sound_ok
      begin
          full_name = File.expand_path(DATA_PATH + "sound/" + name)
          sound = Rubygame::Mixer::Sample.load_audio(full_name)
          return sound
      rescue Rubygame::SDLError => ex
          puts "Cannot load sound " + full_name + " : " + ex
          exit
      end
  end
  IMAGE_LIST = ['unit1r.png','unit2r.png','unit3r.png','unit4r.png','unit4r.png','unit6r.png','unit7r.png']
  # TODO how to do this for all machines at the correct speed?
  FRAME_UPDATE_TIME = 100
  @@pics = []
  @@selected_image = Surface.load_image(DATA_PATH + "/gfx/magiceffect0r.png").zoom([0.2,0.2],true)
  IMAGE_LIST.each do |img|
    @@pics <<  Surface.load_image(DATA_PATH + "/gfx/#{img}")
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
    Rubygame::Mixer::play(@whiff_sound,-1,0)
  end
	def initialize(x,y,rate=0.1)
		super()
    @pic = @@pics.first
    @whiff_sound = load_sound('whiff.wav')
    @animating = true
    @selected = false
    @pic.set_colorkey(@pic.get_at(0,0))
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
    @rect.size = @selected ? @@selected_image.size : @image.size
    base = @speed * time/1000.0
    @rect.centerx = x + @vx * base
    @rect.centery = y + @vy * base
  end
  def animating?()
    @animating
  end
  def draw(destination)
    if @selected
      x,y = @rect.center 
      w = @@selected_image.w
      h = @@selected_image.h
      x = x - (w/2)
      y = y - (h/2)
      @@selected_image.blit(destination, [x,y,w,h])
      @image.blit(destination, [x+(w-@image.w)/2,y+(h-@image.h)/2,@image.w,@image.h])
    else
      super(destination)
    end
  end
  def update_image(time)
    @pic = @@pics[@frame]
    if @time_since_last_frame_change > FRAME_UPDATE_TIME and animating?
      @frame = (@frame + 1) % IMAGE_LIST.size
      @time_since_last_frame_change = 0
    else
      @time_since_last_frame_change += time
    end
    @image = @pic
  end
end
