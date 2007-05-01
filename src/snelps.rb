#!/usr/bin/env ruby

$: << "#{File.dirname(__FILE__)}/../config"
require "environment"
require "rubygame"
require "rubygame/sfont"
include Rubygame
require "unit"
require "math"
include Ruby3d

$stdout.sync = true
Rubygame.init()

queue = EventQueue.new() # new EventQueue with autofetch
queue.ignore = [ActiveEvent]
clock = Clock.new()
clock.target_framerate = 40

# TODO how to do this for all machines at the correct speed?
FRAME_UPDATE_TIME = 60

puts 'Warning, images disabled' unless 
  ($image_ok = (Rubygame::VERSIONS[:sdl_image] != nil))
puts 'Warning, font disabled' unless 
  ($font_ok = (Rubygame::VERSIONS[:sdl_ttf] != nil))
puts 'Warning, sound disabled' unless
  ($sound_ok = (Rubygame::VERSIONS[:sdl_mixer] != nil))

class MouseSelection
	include Sprites::Sprite
  attr_accessor :start_x, :start_y, :dragging
  def down(pos)
    @start_x = pos.first
    @start_y = pos.last
    @dragging = true
  end
  def up(pos)
		x_array = [@start_x, pos.first].sort
		y_array = [@start_y, pos.last].sort
		@rect = Rect.new(x_array.first,y_array.first,x_array.last - x_array.first ,y_array.last - y_array.first)
  end
  def initialize()
    super
  end
end
class MouseCursor
	include Sprites::Sprite
  IMAGE_LIST = {
    :cursor => ['explosion0.png'],
    :goto => ['explosion0.png','explosion0.png','explosion0.png','explosion0.png','explosion0.png','explosion0.png']
  }
  @@images = {}
  IMAGE_LIST.each do |action, imgs|
    @@images[action] = []
    imgs.each do |img|
      @@images[action] <<  Surface.load_image(DATA_PATH + "gfx/#{img}")
    end
  end
  attr_accessor :animating
  def initialize()
    super
    @current_action = :cursor
    @animating = false
    @frame = 0
    @time_since_last_frame_change = 0
    @image = @@images[@current_action][@frame]
		@rect = Rect.new(400,300,*@image.size)
  end
  def animating?()
    @animating
  end
  def update(time)
    update_image(time)
  end
  def on_order()
    @frame = 0
    @current_action = :goto
    @animating = true
  end

  def update_image(time)
    if @time_since_last_frame_change > FRAME_UPDATE_TIME and animating?
      @frame = (@frame + 1)
      if @frame == IMAGE_LIST[@current_action].size
        @current_action = :cursor
        @animating = false
        @frame = 0
      end
      @time_since_last_frame_change = 0
    else
      @time_since_last_frame_change += time
    end
    @image = @@images[@current_action][@frame]
  end

  def x; @rect.centerx; end
  def y; @rect.centery; end
end

snelps = Sprites::Group.new
snelps.extend(Sprites::UpdateGroup)
mouse_selection = MouseSelection.new
mouse_cursor = MouseCursor.new

# Create the SDL window
screen = Screen.set_mode([800,600])
screen.title = "Snelps"
screen.show_cursor = false

# Not in the pygame version - for Rubygame, we need to 
# explicitly open the audio device.
# Args are:
#   Frequency - Sampling frequency in samples per second (Hz).
#               22050 is recommended for most games; 44100 is
#               CD audio rate. The larger the value, the more
#               processing required.
#   Format - Output sample format.  This is one of the
#            AUDIO_* constants in Rubygame::Mixer
#   Channels -output sound channels. Use 2 for stereo,
#             1 for mono. (this option does not affect number
#             of mixing channels) 
#   Samplesize - Bytes per output sample. Specifically, this
#                determines the size of the buffer that the
#                sounds will be mixed in.
Rubygame::Mixer::open_audio( 22050, Rubygame::Mixer::AUDIO_U8, 2, 1024 )

snelp1 = Snelp.new(100,50)
$obj = snelp1.object_id
snelp1.on_selection
snelp2 = Snelp.new(100,80)
snelp3 = Snelp.new(100,150)
snelps.push(snelp1, snelp2, snelp3)

20.times do
  snelps << Snelp.new(rand(800), rand(600))
end

background_music = snelp1.load_sound("loop.wav")
Rubygame::Mixer::play(background_music,-1,-1)

# Make the background surface
background = Surface.new(screen.size)

#sfont = SFont.new(DATA_PATH + "/fonts/term16.png")
#sfont.render("Love Snelps forever! <3").blit(background,[100,10])
#
TTF.setup()
ttfont = TTF.new(DATA_PATH + "/fonts/freesansbold.ttf",11)
ttfrndr = ttfont.render("Snelps Sandbox",true,[250,250,250])
ttfrndr.blit(background,[70,60])
ttfrndr = ttfont.render("CLICK - tell selected snelps to goto clicked location",true,[250,250,250])
ttfrndr.blit(background,[70,80])
ttfrndr = ttfont.render("CTRL-CLICK - tell selected snelps to teleport to clicked location",true,[250,250,250])
ttfrndr.blit(background,[70,95])
ttfrndr = ttfont.render("A - select all",true,[250,250,250])
ttfrndr.blit(background,[70,110])
ttfrndr = ttfont.render("ESC - deselect all",true,[250,250,250])
ttfrndr.blit(background,[70,125])
ttfrndr = ttfont.render("T - toggle targets",true,[250,250,250])
ttfrndr.blit(background,[70,140])
ttfrndr = ttfont.render("Q - quit",true,[250,250,250])
ttfrndr.blit(background,[70,155])


# Create another surface to test transparency blitting
# BOX
#b = Surface.new([800,50])
#b.fill([150,20,40])
#b.set_alpha(123)# approx. half transparent
#b.blit(background,[20,40])
#background.blit(screen,[0,0])

update_time = 0
fps = 0
mouse_pos = [400,300]

catch(:rubygame_quit) do
	loop do
		queue.each do |event|
			case event
			when MouseMotionEvent
        mouse_cursor.rect.centerx, mouse_cursor.rect.centery = event.pos
			when MouseDownEvent
        mouse_selection.down event.pos
			when MouseUpEvent
        mouse_selection.dragging = false
        if mouse_selection.start_x == event.pos.first and mouse_selection.start_y == event.pos.last
          # clicked
          selection = nil
          snelps.each do |s|
            if s.col_rect.collide_point?(*event.pos)
              selection = true
              selection = s
              break
            end
          end
          if selection
            snelps.each do |s|
              s.on_unselection if s.selected
            end
            selection.on_selection 
          end
          unless selection
            if @ctrl_down
              snelps.each do |s|
                s.order(:teleport_to, event.pos) if s.selected
              end
            else
              snelps.each do |s|
                s.order(:move_to, event.pos) if s.selected
              end
            end
            mouse_cursor.on_order
          end
        else
          # dragged
          mouse_selection.up event.pos
          snelps.each do |s|
            s.on_unselection if s.selected
          end
          snelps.each do |s|
            s.on_selection if s.collide_sprite?(mouse_selection)
          end
        end
			when KeyDownEvent
				case event.key
				when K_ESCAPE
          snelps.each do |s|
            s.on_unselection if s.selected
          end
				when K_LCTRL
          @ctrl_down = true
				when K_Q
					throw :rubygame_quit 
				when K_A
          snelps.each do |s|
            s.on_selection 
          end
				when K_T
          snelps.each do |s|
            s.draw_target = !s.draw_target
          end
				when K_UP
					snelp1.vy = -1
				when K_DOWN
					snelp1.vy = 1
				when K_LEFT
					snelp1.vx = -1
				when K_RIGHT
					snelp1.vx = 1
				end
			when KeyUpEvent
				case event.key
				when K_LCTRL
          @ctrl_down = false
				when K_UP
					snelp1.vy = 0
				when K_DOWN
					snelp1.vy = 0
				when K_LEFT
					snelp1.vx = 0
				when K_RIGHT
					snelp1.vx = 0
				end
			when QuitEvent
				throw :rubygame_quit
			end
		end
#		snelps.undraw(screen, background)
    background.blit(screen,[0,0])
		mouse_cursor.update(update_time)
		snelps.update(update_time)
		snelps.draw(screen)

    #draw the selection box
    if mouse_selection.dragging
      screen.draw_box([mouse_selection.start_x, mouse_selection.start_y],
        [mouse_cursor.x, mouse_cursor.y], [50,200,0])
      screen.draw_box_s([mouse_selection.start_x, mouse_selection.start_y],
        [mouse_cursor.x, mouse_cursor.y], [85,255,0,100])
    end
    
		mouse_cursor.draw(screen)
    
		screen.update()
		update_time = clock.tick()
		unless fps == clock.framerate
			fps = clock.framerate
			screen.title = "Snelps [%d fps]"%fps
		end
	end
end
Rubygame.quit()
