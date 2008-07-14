module MeleeAttacker

  def self.included(target)
    target.add_setup_listener :setup_melee_attacker
  end

  def setup_melee_attacker(args)
    @abilities << :melee_attack
  end

  def melee_attack(args)
     # TODO
  end

end
