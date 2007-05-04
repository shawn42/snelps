require 'socket'
require 'logger'

module Snelps
  class NetServer
    PORT = 5431
    MAX_RECV_SIZE = 1500

    attr_accessor :port, :host

    def initialize(port=PORT, host='')
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
    
        pid = fork
    
        if pid.nil? then
          # child process
          name = from_who[1]
          name ||= from_who[3]
          puts "Got [#{payload[0,59]}] from #{name}:#{from_who[2]}"
          @socket.send "ACK", 0, from_who[3], from_who[1] # remote IP, remote port
          sleep 1
          Process.exit
        else
          Process.detach pid
        end
        
      end
    end

  end
end

if $0 == __FILE__
  svr = Snelps::NetServer.new
  svr.start
end