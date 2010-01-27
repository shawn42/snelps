require 'commands'
require 'publisher'

# this class manages the passing of commands to/from the server
class NetworkManager
  NETWORK_DEBUG = false
  include Commands
  extend Publisher
  can_fire :msg_received

  attr_accessor :wrapped_session

  def wrapped_session=(sess)
    @wrapped_session = sess
    @wrapped_session.when :message_from_server do |msg|
      fire :msg_received, msg
    end
  end

  def push_to_server(msg)
    if @wrapped_session
      @msg_queue ||= []
      @msg_queue << msg
    else
      raise "no wrapped_session"
    end
  end

  def send_all
    # race condition on the queue here?
    return if @msg_queue.nil?
    @msg_queue.each do |msg|
      @wrapped_session.message_to_server msg
    end
    @msg_queue = []
  end
end
