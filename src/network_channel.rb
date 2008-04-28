# NetworkChannel represents a one-way channel of communication with the
# transport protocols abstracted away. Note: a channel can also write to
# other channels to build "distribution lists".
class NetworkChannel 
  extend Publisher
  can_fire :msg_received

  def initialize()
    @mutex = Mutex.new
  end

  def push(obj)
    @mutex.synchronize do
      fire :msg_received, obj
    end
  end
end
