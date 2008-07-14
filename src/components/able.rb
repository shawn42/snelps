# Able means this entity can be given abilities. ie move, melee_attack, etc
module Able

  def self.included(target)
    target.add_setup_listener :setup_able
  end

  def setup_able(args)
    @abilities = []
  end

  # add_ability adds an ability to the entities list,
  # the cooresponding method must be available to be called.
  # ie add_ability :sneeze would require a sneeze method to be defined
  def add_ability(ability)
    @abilities << ability
  end

  def can?(ability)
    @abilities.include? ability
  end

end
