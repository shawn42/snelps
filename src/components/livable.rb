module Livable

  def self.included(target)
#    target.add_setup_listener :setup_melee_attacker
    target.can_fire :death
  end

  def damage(amount)
    self.health -= amount
    die if self.health < 1
  end

  def die()
    teleport_to nil
    fire :death, self 
  end

  def alive?
    self.health > 0
  end


end
