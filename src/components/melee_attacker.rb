module MeleeAttacker
  DEFAULT_MELEE_RANGE = 15
  DEFAULT_MELEE_DAMAGE = 3

  TARGETING_UPDATE_TIME = 300

  def self.included(target)
    target.add_setup_listener :setup_melee_attacker
    target.add_update_listener :update_melee_attacker
  end

  def setup_melee_attacker(args)
    require_components :pathable
    @abilities << :melee_attack

    @targeting_time = 0
  end

  # check status of moving vs attacking
  # - is he running away?
  # - can I reach him now?
  # TODO, what do I do when I am done attacking?
  # say from another command being issued?
  def update_melee_attacker(time)
    if @current_target
      if @targeting_time > TARGETING_UPDATE_TIME
        attack_entity :target => @current_target 
        @targeting_time = 0
      else
        @targeting_time += time
      end
    end
  end

  def melee_attack(args)
    target = args[:target]
    if target.is_a? Array
      attack_location args
    else
      attack_entity args
    end
  end

  # attack at a particular location on the map
  def attack_location(args)
    target = args[:target]
    path_to target.tile_x, target.tile_y 
    # TODO set some sort of anger flag
  end


  def melee_damage(target)
    p "ent[#{target.server_id}] health[#{target.health}]"
    target.health -= DEFAULT_MELEE_DAMAGE
    p "ent[#{target.server_id}] health[#{target.health}]"
  end


  # attack and pursue the targeted entity
  def attack_entity(args)
    target = args[:target]

    if within_range? target
      melee_damage target
    else
      # move closer
      path_to target.tile_x, target.tile_y, [target]

      #save anger for later
      @current_target = target
    end
  end

  def within_range?(target)
      from = Node.new tile_x, tile_y
      to = Node.new target.tile_x, target.tile_y
      dist = Pathfinder.diagonal_heuristic from, to

      range = @range || DEFAULT_MELEE_RANGE

      dist <= range
  end

end
