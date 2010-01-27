class InputManager
  extend Publisher
  can_fire :key_up, :event_received
  
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
    
    @clock = Clock.new do |c|
      c.target_framerate = 250
    end
  end

  def main_loop(game)
    catch(:rubygame_quit) do
      loop do
        @queue.each do |event|
          fire :event_received, event
          case event
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
