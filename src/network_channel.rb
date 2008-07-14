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
    # TODO: is this sync needed? it's expensive
    @mutex.synchronize do
      fire :msg_received, obj
    end
  end

  def <<(cmd)
    push cmd
  end

end
