require 'game_server'
require 'socket'
require 'logger'
require 'commands'
class GameServerProxy
  include Commands
  PORT = 5432
  MAX_RECV_SIZE = 1500

  def initialize(port=PORT, host='')
    @connected = false
    @socket = UDPSocket.new
    @port = port
    @host = host
  end

  def connect_to_game_server()
    @socket.send "CONNECT", 0, @host, @port
    payload, from_who = @socket.recvfrom MAX_RECV_SIZE
#    port = from_who[1]
#    name = from_who[2]
#    name ||= from_who[3]
    if payload == SUCCESS
      @connected = true
      puts "Connected successfully"
    else
      raise("Could not connect to server #{@host}#{@port}")
    end
  end

  def start
    # connect to server, add self as a client
    connect_to_game_server
    # listen for cmds to server
    # also send commands to server
#    count = 1
#    data = 'x' * 3
#    
#    10.times do
#      @socket.send "#{count} -> ACK? -> #{data}", 0, @host, @port
#    
#      count += 1
#  
#      payload, from_who = @socket.recvfrom MAX_RECV_SIZE
#
#      name = from_who[1]
#      name ||= from_who[3]
#      puts "Got [#{payload[0,59]}] from #{name}:#{from_who[2]}"
#    end
  end
end
if $0 == __FILE__
  GameServerProxy.new.start
end
