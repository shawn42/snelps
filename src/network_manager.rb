require 'commands'
require 'publisher'

# this class manages the passing of commands to/from the server
class NetworkManager
  NETWORK_DEBUG = false
  include Commands
  extend Publisher
  can_fire :msg_received

  attr_accessor :wrapped_session

  def initialize
    @mutex = Mutex.new
  end

  def wrapped_session=(sess)
    @wrapped_session = sess
    @wrapped_session.when :message_from_server do |msg|
      fire :msg_received, msg
    end
  end

  def push_to_server(msg)
    if @wrapped_session
      @wrapped_session.message_to_server msg
    else
      raise "no wrapped_session"
    end
  end
end
