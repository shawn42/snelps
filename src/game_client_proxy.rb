require 'game_server_proxy'
require 'socket'
require 'logger'
require 'commands'

class GameClientProxy
  include Commands
  MAX_RECV_SIZE = 1500
  
  attr_accessor :port, :host

  def initialize(game_server, port=GameServerProxy::PORT, host='' )
    @game_server = game_server
    @port = port
    @host = host
    @log = Logger.new STDOUT
    @log.datetime_format = ""
  end

  def start
    @socket = UDPSocket.new
    @socket.bind host, port
    @socket.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1

    @log.info "Started server on #{Socket.gethostname}:#{port}"
    
    loop do                               
      payload, from_who = @socket.recvfrom MAX_RECV_SIZE
      client_ip = from_who[3]
      client_port = from_who[1]

      if payload == CLIENT_CONNECT
        puts "CONNECTING..."
        @socket.send SUCCESS, 0, client_ip, client_port # remote IP, remote port
      elsif payload[0..UNIT_REQ.size-1] == UNIT_REQ
        puts "UNIT_REQING..."
        args = payload.split(':')[1..-1]
        unit_id = @game_server.create_unit("#{client_ip}:#{client_port}", args[0], args[1], args[2])
        msg = [SUCCESS, unit_id].join ":"
        @socket.send msg, 0, client_ip, client_port
      end
    end
  end
end

if $0 == __FILE__
  GameClientProxy.new.start
end
