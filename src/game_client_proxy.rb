require 'game_server_proxy'
require 'socket'
require 'logger'
require 'commands'

class GameClientProxy
  include Commands
  MAX_RECV_SIZE = 1500
  
  attr_accessor :port, :host

  def initialize(port=GameServerProxy::PORT, host='')
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
      @clients ||= []
      @clients << "#{client_ip}:#{client_port}"
      @socket.send SUCCESS, 0, client_ip, client_port # remote IP, remote port
    end
  end
end

if $0 == __FILE__
  GameClientProxy.new.start
end
