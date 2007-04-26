#!/usr/bin/env ruby

$: << "#{File.dirname(__FILE__)}/../config"
require "environment"
require "rubygame"
include Rubygame
require "unit"

$stdout.sync = true
Rubygame.init()

queue = EventQueue.new() # new EventQueue with autofetch
queue.filter = [ActiveEvent]
clock = Rubygame::Time::Clock.new()
clock.desired_fps = 40

unless ($gfx_ok = (VERSIONS[:sdl_gfx] != nil))
  raise "SDL_gfx is not available. Bailing out." 
end

class MouseSelection
	include Sprites::Sprite
  attr_accessor :start_x, :start_y
  def down(pos)
    @start_x = pos.first
    @start_y = pos.last
  end
  def up(pos)
		x_array = [@start_x, pos.first].sort
		y_array = [@start_y, pos.last].sort
		@rect = Rect.new(x_array.first,y_array.first,x_array.last - x_array.first ,y_array.last - y_array.first)
  end
  def initialize()
    super
  end
  def update(time)
  end
end

snelps = Sprites::Group.new
snelps.extend(Sprites::UpdateGroup)
mouse_selection = MouseSelection.new

# Create the SDL window
screen = Screen.set_mode([640,480])
screen.set_caption("Snelps","revenge of the snelp!")
screen.show_cursor = true;


snelp1 = Snelp.new(100,50)
snelp2 = Snelp.new(200,80)
snelp3 = Snelp.new(100,350)
snelps.push(snelp1, snelp2, snelp3)

20.times do
  snelps << Snelp.new(rand(600), rand(400))
end
# Make the background surface
background = Surface.new(screen.size)

sfont = SFont.new(DATA_PATH + "/fonts/term16.png")
sfont.render("Love Snelps forever! <3").blit(background,[100,10])

TTF.setup()
ttfont = TTF.new(DATA_PATH + "/fonts/freesansbold.ttf",11)
ttfrndr = ttfont.render("Drowing of strings....",true,[250,250,250])
ttfrndr.blit(background,[70,200])


# Create another surface to test transparency blitting
b = Surface.new([200,50])
b.fill([150,20,40])
b.set_alpha(123)# approx. half transparent
b.blit(background,[20,40])
background.blit(screen,[0,0])

update_time = 0
fps = 0

catch(:rubygame_quit) do
	loop do
		queue.each do |event|
			case event
			when MouseDownEvent
        mouse_selection.down event.pos
			when MouseUpEvent
        if mouse_selection.start_x == event.pos.first and mouse_selection.start_y == event.pos.last
          # clicked
          selection = nil
          snelps.each do |s|
            if s.col_rect.collide_point?(event.pos)
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
            snelps.each do |s|
              s.order(event.pos) if s.selected
            end
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
					throw :rubygame_quit 
				when K_Q
					throw :rubygame_quit 
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
		snelps.undraw(screen,background)
		snelps.update(update_time)

		snelps.draw(screen)
		screen.update()
		update_time = clock.tick()
		unless fps == clock.fps
			fps = clock.fps
			screen.set_caption("Snelps [%d fps]"%fps)
		end
	end
end
