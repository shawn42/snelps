require 'commands'
# in charge of pumping off events from the server and organizing them
# into turns
class TurnManager
  include Commands
  attr_accessor :turn_num, :turns
  constructor :network_manager

  def setup()
    @turn_num = 0
    @network_manager.when :msg_received do |e| 
      # add to turn
    end
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

end
