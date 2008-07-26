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
    teleport_to nil
    fire :death, self 
  end


end
