#!/usr/bin/env ruby
$: << "#{File.dirname(__FILE__)}/../config"
require "environment"
require 'server_unit'
require 'game_client_proxy'
class GameServer
  def initialize()
    @clients = []
    @units = []
    @game_client_proxy = GameClientProxy.new self
    @game_client_proxy.start
  end

  def client_connect(ident_token)
    @clients << "#{client_ip}:#{client_port}"
  end
  def create_unit(client, unit_type, x, y)
    new_unit = ServerUnit.new unit_type, x, y
    @units << new_unit
    new_unit.object_id
  end
end

if $0 == __FILE__
  GameServer.new
end
