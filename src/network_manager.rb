require 'network_channel'
require 'commands'

# this class manages the passing of commands to/from the server
class NetworkManager
  NETWORK_DEBUG = false
  include Commands
  attr_accessor :channels

  def initialize()
    @channels = {}
  end

  def [](channel)
    @channels[channel]
  end

end

# this class mocks out the network and just "round trips messages"
class NetworkManager

  def initialize()
    @log = File.open 'network_log.txt', 'w' if NETWORK_DEBUG
    @channels = {}
    @channels[:to_server] = NetworkChannel.new
    @channels[:from_server] = NetworkChannel.new
    @channels[:turns_from_server] = NetworkChannel.new
    @turn_num = 0

    @channels[:to_server].when :msg_received do |msg|
      @log.puts msg if NETWORK_DEBUG

      handle_server_msg msg
    end
    @mock_server_thread = Thread.new do
      # add turn messages like the server would
      sleep 10
      loop do
        sleep 0.3
        @turn_num += 1
        @channels[:turns_from_server].push("TURN:#{@turn_num}")
      end
    end
  end

  def handle_server_msg(msg)
    begin
      unless msg.nil?
        cmd = msg.split(':')[0]
        case cmd
          when HEARTBEAT
            puts msg
          when PLAYER_JOIN
            @player_id ||= 0
            @player_id += 1
            # L means that this is your local player
            msg += ":#{@player_id}:L"
            @channels[:from_server].push msg
          else
            @channels[:from_server].push msg
        end
      end
    rescue Exception => ex
      p ex.backtrace
      p ex
    end
  end

  def [](channel)
    @channels[channel]
  end

end
