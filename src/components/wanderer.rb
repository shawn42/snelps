module Wanderer

  def self.included(target)
#    p "target:[#{target.methods.sort.inspect}]"
#    p "target:[#{target.class}]"
    target.add_update_listener :update_wanderer 
    target.add_setup_listener :setup_wanderer 
  end

  def setup_wanderer(args)
    @orig_x = x
    @orig_y = y
  end

  def update_wanderer(time)
    unless moving?
      # TODO this only wanders right and down
      x = @orig_x + rand(@range) 
      y = @orig_x + rand(@range)
      cmd = "#{ENTITY_MOVE}:#{entity.server_id}:#{x}:#{y}"
      fire :network_msg_to, cmd
    end
  end

end
