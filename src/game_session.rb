require 'drb'
class GameSession
  include DRbUndumped

  attr_reader :player_number

  def initialize(opts)
    @game_hub = opts[:game_hub]
    @player_number = opts[:player_number]
    @queue = Queue.new
  end

  # API for use by remote clients:
  
  # Return next message from the server. Blocks until messages
  # available.
  def next_message
    @queue.deq
  end

  # Send a message into the game hub.
  def message_to_server(m)
    @game_hub.broadcast(m)
  end

  # Quit the remote session
  def quit
    @game_hub.quit(self)
  end

  # API for use by the GameHub on the server:

  def message_to_client(m)
    @queue.enq m
  end
end
