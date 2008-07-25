module Livable

  def self.included(target)
#    target.add_setup_listener :setup_melee_attacker
    target.can_fire :death
  end

  def damage(amount)
    self.health -= amount
    die if self.health < 1
    p "ent[#{@server_id}] health[#{self.health}]"
  end

  def die()
    # the grid stuff doesn't really belong here
    @grid.leave @last_tile_x, @last_tile_y unless @last_tile_x.nil?
    @grid.leave @tile_x, @tile_y
    fire :death, self 
  end


end
