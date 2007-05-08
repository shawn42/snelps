require "rubygame"
require "rubygame/sfont"
include Rubygame
class InputManager
  def initialize()
    @queue = EventQueue.new() # new EventQueue with autofetch
    @queue.ignore = [ActiveEvent]
    @clock = Clock.new()
    @clock.target_framerate = 40
  end

  def main_loop(game)
    catch(:rubygame_quit) do
      loop do
        @queue.each do |event|
          case event
          when MouseMotionEvent
            game.mouse_motion event
          when KeyDownEvent
            case event.key
            when K_ESCAPE
              throw :rubygame_quit 
            when K_Q
              throw :rubygame_quit 
            end
          when QuitEvent
            throw :rubygame_quit
          end
        end

        game.update @clock.tick
      end
    end
  end
end
