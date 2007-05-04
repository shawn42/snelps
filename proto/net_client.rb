require 'socket'
require 'logger'
require 'net_server'

module Snelps
  class NetClient
    
    MAX_RECV_SIZE = 1500
    
    def initialize(port=Snelps::NetServer::PORT, host='')
      @socket = UDPSocket.new
      @port = port
      @host = host
    end

    def start
      count = 1
      data = 'x' * 3
      
      10.times do
        @socket.send "#{count} -> ACK? -> #{data}", 0, @host, @port
      
        count += 1
    
        payload, from_who = @socket.recvfrom MAX_RECV_SIZE

        name = from_who[1]
        name ||= from_who[3]
        puts "Got [#{payload[0,59]}] from #{name}:#{from_who[2]}"
      end
    end
  end
end

if $0 == __FILE__
  client = Snelps::NetClient.new
  client.start
end