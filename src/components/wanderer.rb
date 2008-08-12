module Wanderer
  include Commands

  def self.included(target)
    target.add_update_listener :update_wanderer 
    target.add_setup_listener :setup_wanderer 
  end

  def setup_wanderer(args)
    require_components :pathable, :movable, :positionable, :able
    @orig_x = @tile_x
    @orig_y = @tile_y
    self.range
    self.wandering_idle_time
    @range_options = (0-@range..@range).to_a
    @range_size = 2*@range
    @idle_timer = 0
  end


  def update_wanderer(time)
    if idle?
      @idle_timer += time
    end
    if @idle_timer > @wandering_idle_time
      @idle_timer = 0
      # validate these positions before sending to the pathfinder
      wander_x = @orig_x + @range_options[rand(@range_size)]
      wander_y = @orig_y + @range_options[rand(@range_size)]
      until wander_x != x and wander_y != y
        wander_x = @orig_x + @range_options[rand(@range_size)]
        wander_y = @orig_y + @range_options[rand(@range_size)]
      end
      
      # TODO this needs to fire out to sync w/ network
      cmd = "#{ENTITY_MOVE}:#{@server_id}:#{wander_x}:#{wander_y}"
#      fire :network_msg_to,cmd
      self.path = create_new_path wander_x, wander_y

    end
  end

end
