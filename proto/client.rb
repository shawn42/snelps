require 'drb'

class Client
  def run
    # Connect to server
    @port = 4400
    @game_hub = DRbObject.new(nil, "druby://0.0.0.0:#{@port}")
    @game_hub.ping
    puts "(Connected to server.)"

    # Join game
    game_session = @game_hub.join
    # Wrap the game session
    @wrapped_session = WrappedGameSession.new(game_session)
    puts "(Joined game, I'm player number #{@wrapped_session.player_number})"

    # Listen for incoming messages
    @wrapped_session.when :message_from_server do |m|
      show_server_message m
    end

    # Generate some random player activity
    10.times do 
      sleep rand(5)
      @wrapped_session.message_to_server choose_random_message
    end

    # Quit
    @wrapped_session.quit
    puts "(Told the server I'm quitting; exiting normally.)"
  end

  def show_server_message(m)
    puts "[#{Time.now}] FROM SERVER: #{m}"
  end

  def choose_random_message
    @choices ||= [
      "No human being would stack books like this.",
      "GET HER!!",
      "That was your whole plan? 'Get her'? That was scientific.",
      "Back off man; I'm a scientist.",
      "If there's a steady pay check in it, I'll believe anything you say.",
    ]
    text = "(#{@wrapped_session.player_number}) #{@choices[rand(5)]}"
    text
  end
end

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
        fire :message_from_server, message
      end
    end
  end
end

Client.new.run
