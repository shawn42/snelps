#!/usr/bin/env ruby
require 'drb'
require 'game_session'
require 'game_hub'

class Server
  DEFAULT_PORT = 4400
  def start
    @hub = GameHub.new

    port = DEFAULT_PORT
    DRb.start_service("druby://0.0.0.0:#{port}", @hub)
    puts "Game hub running on port #{port}"
    DRb.thread.join
  end
end

Server.new.start
