require 'drb'
require 'wrapped_game_session'
require 'game_hub'
require 'game_session'
class ConnectionManager
  DEFAULT_PORT = 4400
  DEFAULT_SERVER = "0.0.0.0"

  def connect_to_server
    # Connect to server
    @game_hub = DRbObject.new(nil, "druby://#{DEFAULT_SERVER}:#{DEFAULT_PORT}")
    @game_hub.ping
    puts "(Connected to server.)"

    # Join game
    game_session = @game_hub.join
    # Wrap the game session
    @wrapped_session = WrappedGameSession.new(game_session)
    @wrapped_session
  end

  def connect_local
    @game_hub = GameHub.new
    @game_hub.ping
    puts "(Connected to server.)"

    # Join game
    game_session = @game_hub.join
    @wrapped_session = WrappedGameSession.new(game_session)
  end

  def player_id
    @wrapped_session.player_number
  end

  def quit
    # Quit
    @wrapped_session.quit
  end

end
