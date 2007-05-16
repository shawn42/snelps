require 'game_client_proxy'
class GameServer
  def initialize()
    @game_client_proxy = GameClientProxy.new
    @game_client_proxy.start
  end
end

if $0 == __FILE__
  GameServer.new
end
