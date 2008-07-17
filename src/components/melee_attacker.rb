module MeleeAttacker
  DEFAULT_MELEE_RANGE = 15
  DEFAULT_MELEE_DAMAGE = 15

  def self.included(target)
    target.add_setup_listener :setup_melee_attacker
    target.add_update_listener :update_melee_attacker
  end

  def setup_melee_attacker(args)
    require_components :pathable
    @abilities << :melee_attack
  end

  # check status of moving vs attacking
  # - is he running away?
  # - can I reach him now?
  def update_melee_attacker(time)
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
    attack_cmd,entity_id,dest_tile_x,dest_tile_y = cmd.split ':'

    entity_id = entity_id.to_i
    dest_tile_x = dest_tile_x.to_i
    dest_tile_y = dest_tile_y.to_i
    
    entity = @entity_manager.find_entity_by_id entity_id

    entity.path_to dest_tile_x, dest_tile_y if entity.is? :pathable
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
      # TODO make pathfinder able to ignore a particular object(s)
      from = [tile_x, tile_y]
      to = [target.tile_x, target.tile_y]
      max = 80
      new_path = Pathfinder.new(z, @entity_manager, @map.w, @map.h).find(from,to,max)
      if new_path.nil?
        stop_animating
      else
        self.path = new_path
      end

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
