require 'commands'
# in charge of pumping off events from the server and organizing them
# into turns
class TurnManager
  include Commands
  attr_accessor :turn_num, :turns
  constructor :network_manager

  def setup()
    @turn_num = 0
  end

  def handle_turn(msg)
    cmd, val = msg.split ":"
    val = val.to_i
    if cmd == TURN_NUM
      if val == (@turn_num + 1)
        @turn_num = (@turn_num + 1)
      else
        puts "OUT OF SYNC!!!"
        puts "EXPECTED TURN:#{@turn_num + 1} but got #{val}"
      end
    end
  end
  
  def start(game)
    @game = game
    @network_manager[:turns_from_server].when :msg_received do |cmd|
      handle_turn(cmd)
    end

    # heartbeat to let the server know that we're still here... is this
    # needed?
    @heartbeat_thread = Thread.new do
      loop do
        @network_manager[:to_server].push "#{HEARTBEAT}:TOKEN"
        sleep 10
      end
    end
  end

end
