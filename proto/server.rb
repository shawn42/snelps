require 'drb'
require 'thread'

class Server
  def start
    @hub = GameHub.new

    @port = 4400
    DRb.start_service("druby://0.0.0.0:#{@port}", @hub)
    puts "Game hub running on port #{@port}"
    DRb.thread.join
  end
end

class GameHub
  def initialize
    @player_count = 0
    @mutex = Mutex.new
    @sessions = []
  end

  def ping
    "pong"
  end

  def join
    announcement = "?"
    session = "UNSET"
    sessions_lock do
      @player_count += 1
      session = GameSession.new(:game_hub => self, :player_number => @player_count)
      @sessions << session
      announcement = "PLAYER #{session.player_number} JOINED"
    end
    broadcast announcement
    return session
  end

  def broadcast(m)
    puts "(Broadcasting to all players: #{m})"
    sessions_lock do
      @sessions.each do |session|
        session.message_to_client m
      end
    end
  end

  def quit(session)
    announcement = "?"
    sessions_lock do
      @sessions.delete(session)
      announcement = "PLAYER #{session.player_number} HAS QUIT"
    end
    broadcast announcement
  end
  
  private
  def sessions_lock
    @mutex.synchronize do
      yield
    end
  end
end


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

Server.new.start
