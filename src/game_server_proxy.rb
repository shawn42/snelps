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
    @socket.send CLIENT_CONNECT, 0, @host, @port
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

  def create_unit(unit_type, x, y)
    # TODO, make request to server and get the server's id for this unit for
    # tracking
    msg = [UNIT_REQ,unit_type,x,y].join ':'
    @socket.send msg, 0, @host, @port
    payload, from_who = @socket.recvfrom MAX_RECV_SIZE
    if payload[0..SUCCESS.size - 1] == SUCCESS
      args = payload.split(':')[1..-1]    
      return args[1]
    else
      raise("could not create a unit")
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
