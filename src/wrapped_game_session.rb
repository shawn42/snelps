require 'publisher'
class WrappedGameSession
  extend Publisher
  can_fire :message_from_server

  def initialize(game_session)
    @game_session = game_session
    spin_off_message_listener
  end

  def player_number
    @game_session.player_number
  end

  def message_to_server(msg)
#    puts "message_to_server: #{msg}"
    @game_session.message_to_server(msg)
  end

  def quit
    @game_session.quit
  end

  private

  def spin_off_message_listener
    @listening = true
    @listener_thread = Thread.new do
      while @listening
        message = @game_session.next_message
#        puts "firing from sess: #{message}"
        fire :message_from_server, message
      end
    end
  end
end
