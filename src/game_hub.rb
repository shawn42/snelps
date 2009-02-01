require 'thread'

class GameHub
  def initialize(local=false)
    @player_count = 0
    @mutex = Mutex.new unless local
    @sessions = []
  end

  def ping
    "pong"
  end

  def join
#    announcement = "?"
    session = "UNSET"
    sessions_lock do
      @player_count += 1
      session = GameSession.new(:game_hub => self, :player_number => @player_count)
      @sessions << session
#      announcement = "PLAYER:#{session.player_number} JOINED"
    end
#    broadcast announcement
    return session
  end

  def broadcast(m)
#    puts "(Broadcasting to all players: #{m})"
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
    if @mutex
      @mutex.synchronize do
        yield
      end
    else
      yield
    end
  end
end
