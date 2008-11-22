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
    ability == :act_upon or @abilities.include? ability
  end

  # Return an ordered list of available actions based on the
  # target.  Used by ent_manager for mouse-cursor changes when
  # hovering over a target.
  def actions(args)
    if args
      abs = []
      for ability in @abilities
        abs << ability if respond_to?("#{ability}_targets?") and send("#{ability}_targets?", args)
      end
      return abs
    else
      return @abilities
    end
  end

  # Will be called on each selected entity with the given target
  # info.
  def act_upon(args)
    send actions(args).first, args
  end

end
