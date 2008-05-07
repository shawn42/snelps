class InputManager
  extend Publisher
  can_fire :key_up
  
  constructor :mouse_manager
  def setup()
    @queue = EventQueue.new
    @queue.ignore = [
      ActiveEvent,
      JoyAxisEvent,
      JoyBallEvent,
      JoyDownEvent,
      JoyHatEvent,
      JoyUpEvent,
      ResizeEvent
    ]
    @clock = Clock.new
    #seems to max out at around 18 anyways
    @clock.target_framerate = 17
  end

  def main_loop(game)
    catch(:rubygame_quit) do
      loop do
        @queue.each do |event|
          case event
          when MouseMotionEvent
            @mouse_manager.mouse_motion event
          when MouseDownEvent
            @mouse_manager.mouse_down event
          when MouseUpEvent
            @mouse_manager.mouse_up event
          when KeyDownEvent
            case event.key
            when K_F
              puts "Framerate:#{@clock.framerate}"
            end
          when KeyUpEvent
            fire :key_up, event
          when QuitEvent
            throw :rubygame_quit
          end
        end

        game.update @clock.tick
      end
    end
  end
end
