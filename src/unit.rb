#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"

class Snelp
	include Sprites::Sprite
  MAX_X = 800
  MAX_Y = 600
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
  IMAGE_OFFSET = 0 # BIRDS
#  IMAGE_OFFSET = 64 # GLOBS
#  IMAGE_OFFSET = 128 # SWIMMERS
  IMAGE_LIST = {
    :se => ["unit#{IMAGE_OFFSET + 0}r.png","unit#{IMAGE_OFFSET + 1}r.png","unit#{IMAGE_OFFSET + 2}r.png","unit#{IMAGE_OFFSET + 3}r.png","unit#{IMAGE_OFFSET + 4}r.png","unit#{IMAGE_OFFSET + 5}r.png","unit#{IMAGE_OFFSET + 6}r.png","unit#{IMAGE_OFFSET + 7}r.png"],
    :s => ["unit#{IMAGE_OFFSET + 8}r.png","unit#{IMAGE_OFFSET + 9}r.png","unit#{IMAGE_OFFSET + 10}r.png","unit#{IMAGE_OFFSET + 11}r.png","unit#{IMAGE_OFFSET + 11}r.png","unit#{IMAGE_OFFSET + 13}r.png","unit#{IMAGE_OFFSET + 14}r.png","unit#{IMAGE_OFFSET + 15}r.png"],
    :sw => ["unit#{IMAGE_OFFSET + 16}r.png","unit#{IMAGE_OFFSET + 17}r.png","unit#{IMAGE_OFFSET + 18}r.png","unit#{IMAGE_OFFSET + 19}r.png","unit#{IMAGE_OFFSET + 20}r.png","unit#{IMAGE_OFFSET + 21}r.png","unit#{IMAGE_OFFSET + 22}r.png","unit#{IMAGE_OFFSET + 23}r.png"],
    :w => ["unit#{IMAGE_OFFSET + 24}r.png","unit#{IMAGE_OFFSET + 25}r.png","unit#{IMAGE_OFFSET + 26}r.png","unit#{IMAGE_OFFSET + 27}r.png","unit#{IMAGE_OFFSET + 28}r.png","unit#{IMAGE_OFFSET + 29}r.png","unit#{IMAGE_OFFSET + 30}r.png","unit#{IMAGE_OFFSET + 31}r.png"],
    :nw => ["unit#{IMAGE_OFFSET + 32}r.png","unit#{IMAGE_OFFSET + 33}r.png","unit#{IMAGE_OFFSET + 34}r.png","unit#{IMAGE_OFFSET + 35}r.png","unit#{IMAGE_OFFSET + 36}r.png","unit#{IMAGE_OFFSET + 37}r.png","unit#{IMAGE_OFFSET + 38}r.png","unit#{IMAGE_OFFSET + 39}r.png"],
    :n => ["unit#{IMAGE_OFFSET + 40}r.png","unit#{IMAGE_OFFSET + 41}r.png","unit#{IMAGE_OFFSET + 42}r.png","unit#{IMAGE_OFFSET + 43}r.png","unit#{IMAGE_OFFSET + 44}r.png","unit#{IMAGE_OFFSET + 45}r.png","unit#{IMAGE_OFFSET + 46}r.png","unit#{IMAGE_OFFSET + 47}r.png"],
    :ne => ["unit#{IMAGE_OFFSET + 48}r.png","unit#{IMAGE_OFFSET + 49}r.png","unit#{IMAGE_OFFSET + 50}r.png","unit#{IMAGE_OFFSET + 51}r.png","unit#{IMAGE_OFFSET + 52}r.png","unit#{IMAGE_OFFSET + 53}r.png","unit#{IMAGE_OFFSET + 54}r.png","unit#{IMAGE_OFFSET + 55}r.png"],
    :e => ["unit#{IMAGE_OFFSET + 56}r.png","unit#{IMAGE_OFFSET + 57}r.png","unit#{IMAGE_OFFSET + 58}r.png","unit#{IMAGE_OFFSET + 59}r.png","unit#{IMAGE_OFFSET + 60}r.png","unit#{IMAGE_OFFSET + 61}r.png","unit#{IMAGE_OFFSET + 62}r.png","unit#{IMAGE_OFFSET + 63}r.png"],
  }
  @@images = {}
  DEATH_SEQUENCE = ['death9r.png','death8r.png','death7r.png','death6r.png','death5r.png','death4r.png','death3r.png','death2r.png','death1r.png','death0r.png']
  @@selected_image = Surface.load_image(DATA_PATH + "/gfx/magiceffect0r.png").zoom([0.15,0.15],true)
  IMAGE_LIST.each do |dir, imgs|
    @@images[dir] = []
    imgs.each do |img|
      @@images[dir] <<  Surface.load_image(DATA_PATH + "/gfx/#{img}")
    end
  end
  @@images[:death] = []
  DEATH_SEQUENCE.each do |img|
    @@images[:death] <<  Surface.load_image(DATA_PATH + "/gfx/#{img}")
  end

	attr_accessor :speed, :frame, :animating, :selected, :direction, :draw_target, :dying
  def x()
    @rect.centerx
  end
  def y()
    @rect.centery
  end
  def on_selection()
    @selected = true
  end
  def on_unselection()
    @selected = false
  end
  def move_to(pos)
    set_destination! pos[0], pos[1]
    @animating = true
    Rubygame::Mixer::play(@whiff_sound,2,0)
		@speed = 130 + rand(10)
    @last_dest = nil
  end
  def start_death()
    unless @dying
      Rubygame::Mixer::play(@whiff_sound,2,0)
      @frame = DEATH_SEQUENCE.size - 1
      @dying = true
    end
  end
  def teleport_to(pos)
    @rect.centerx = pos[0]
    @rect.centery = pos[1]
    set_destination! @dest.x, @dest.y
  end
  def order(action, pos)
    self.send action, pos
  end
  def get_direction(x,y,new_x,new_y)
    if x == @dest.x
      if y == @dest.y
        # stay the same, cause we're standing still
        @animation_direction
      elsif y > @dest.y
        :n
      elsif y < @dest.y
        :s
      end
    elsif x > @dest.x
      if y == @dest.y
        :w
      elsif y > @dest.y
        :nw
      elsif y < @dest.y
        :sw
      end
    elsif x < @dest.x
      if y == @dest.y
        :e
      elsif y > @dest.y
        :ne
      elsif y < @dest.y
        :se
      end
    end
  end
  def set_destination!(new_x,new_y)
    x,y = @rect.center

    new_x = [0,new_x].max
    new_x = [MAX_X,new_x].min
    new_y = [0,new_y].max
    new_y = [MAX_Y,new_y].min

    @dest = Vector.new(new_x, new_y, 0)
    @direction = Vector.new @dest.x - x, @dest.y - y, 0

    @animation_direction = get_direction x, y, @dest.x, @dest.y
    @direction.normalize!
  end
	def initialize(x,y,rate=0.1)
		super()
    @animation_direction = :se
    @pic = @@images[@animation_direction].first
    @whiff_sound = load_sound('whiff.wav')
    @animating = true
    @selected = false
    @pic.set_colorkey(@pic.get_at(0,0))
		@rate = rate
		@speed = 70 + rand(5) - 4
		@image = @pic
		@frame = rand 8
    @time_since_last_frame_change = 0
		@rect = Rect.new(x,y,*@pic.size)

    set_destination! rand(MAX_X), rand(MAX_Y)
	end
  def update(time)
    x,y = @rect.center
    self.update_image(time)
    @rect.size = @selected ? @@selected_image.size : @image.size
    base = @speed * time/1000.0

    @groups.each do |g|
      g.each do |s|
        unless s === self 
          if  self.collide_sprite? s
            @last_collision = s
            @last_dest ||= []
            @last_dest << @dest

            # REVERSE ########
#              new_dest = Vector.new(x + rand(10),y + rand(10),0) + (@direction* 0.5 *  -@speed)
            #########

            # AWAY ########
#              new_dest = Vector.new(x + rand(10),y + rand(10),0) + (Vector.new(x - s.rect[0], y - s.rect[1],0) * 0.5 * -@speed)
            new_dest = Vector.new(x + rand(10),y + rand(10),0) + Vector.new(x - s.rect[0], y - s.rect[1],0)
            #########

            # REFLECT ########
#              collision_normal = @direction.cross s.direction
#              collision_normal.normalize!
#              relative_velocity = @speed + s.speed
#              fCr = 1 # not sure what this is
#              j = ((collision_normal * relative_velocity) * -(1+fCr)) 
#              j = j /
#                ((collision_normal.dot(collision_normal)) * 2)
#              new_dest = Vector.new(x,y,0) + (j.cross(collision_normal))
            #########

            set_destination! new_dest.x, new_dest.y
            @speed = 130 + rand(15)
            break
          end
        end
      end
    end
    
    if ((x - @dest.x).abs < 5 and (y - @dest.y).abs < 5)
      if not @last_dest.nil? and not @last_dest.empty?
        last_dest = @last_dest.pop
        set_destination!(last_dest.x, last_dest.y)
      else
        set_destination!(rand(MAX_X), rand(MAX_Y)) 
        @speed = 70 + rand(15)
      end
    end

    move = @direction * base
    @rect.centerx = x + move.x
    @rect.centery = y + move.y
  end
  def animating?()
    @animating
  end
  def draw(destination)
    x,y = @rect.center 
    if @selected
      w = @@selected_image.w
      h = @@selected_image.h
      x = x - (w/2)
      y = y - (h/2)
      @@selected_image.blit(destination, [x,y,w,h])
      @image.blit(destination, [x+(w-@image.w)/2,y+(h-@image.h)/2,@image.w,@image.h])
    else
      super(destination)
    end
    if @draw_target
      destination.draw_box [@rect.x, @rect.y], [@rect.x + @rect.w, @rect.y + @rect.h], [200,200,100]
      unless @last_dest.nil? or @last_dest.empty?
        destination.draw_line [x, y], [@last_dest.first.x, @last_dest.first.y], [200,20,100]
      end
      destination.draw_line [x, y], [@dest.x, @dest.y], [200,200,100]
    end
  end
  def update_image(time)
    if @time_since_last_frame_change > FRAME_UPDATE_TIME and animating?
      if @dying
        @frame = (@frame - 1)
        self.kill if @frame == 0
      else
        @frame = (@frame - 1) % IMAGE_LIST[@animation_direction].size
      end
      @time_since_last_frame_change = 0
    else
      @time_since_last_frame_change += time
    end
    animation_key = @dying ? :death : @animation_direction
    @image = @@images[animation_key][@frame]
    puts "#{animation_key}:#{@frame} [#{@dying}]" if @image.nil?
  end
end
