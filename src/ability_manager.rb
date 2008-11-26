$: << "../lib"
require 'yaml'
require 'publisher'

class AbilityManager
  extend Publisher

  can_fire :sound_play, :create_ent

  constructor :resource_manager
  
  def setup()
    @abilities_config = @resource_manager.load_gameplay_config "abilities_defs"
  end

  def selection_area(entities)
    min_x = nil
    min_y = nil
    max_x = nil
    max_y = nil
    for ent in entities
      x = ent.tile_x
      y = ent.tile_y
      min_x = x if min_x.nil? or x < min_x
      min_y = y if min_y.nil? or y < min_y 
      max_x = x if max_x.nil? or x > max_x
      max_y = y if max_y.nil? or y > max_y
    end
    #area
    #(max_x-min_x) * (max_y-min_y)
    (max_x-min_x) + (max_y-min_y)
  end

  def abilities_for(entity_selection)
    return [] if entity_selection.nil? or entity_selection.entities.empty?

    types = {:entity => 0}
    ents = entity_selection.entities.values
    for ent in ents
      types[ent.entity_type] = 0 if types[ent.entity_type].nil?
      types[ent.entity_type] += 1
      types[:entity] += 1
    end

    allowed_abilities = ents.collect{|e| e.is?(:able) ? e.actions(nil) : []}.flatten.uniq
    for ability_type, abilities in @abilities_config  
      for name, ability_def in abilities
        # if selection allows for ability, add it
        sufficient_ents = true
        for ent_type, num in ability_def[:entities]
          if types[ent_type].nil? or types[ent_type] < num
            sufficient_ents = false
          end
        end
        if sufficient_ents
          if selection_area(ents) > ability_def[:morph_range]
            sufficient_ents = false
          end
        end

        allowed_abilities << name if sufficient_ents
      end
    end
    allowed_abilities
  end

  # builds the network command(s) for the given action
  def command_for(selection, action, target)
    cmds = []

    ent_ids = selection.entities.values.collect{|e|e.server_id}.join ","

    if target.is_a? Array
      # either target a location
      cmds << "ENT_#{action.to_s.upcase}:#{ent_ids}:#{target[0]}:#{target[1]}"
    else
      # or target an entity
      cmds << "ENT_#{action.to_s.upcase}:#{ent_ids}:#{target.server_id}"
    end

    cmds
  end

  # execute the given ability
  def execute_ability(ability, selected_ents, target)
    ab_sym = nil
    if ability.nil? or ability.empty?
      # TODO add some logic here.. based on target
      # will we give the user some auto-AI here to determine
      # auto-group actions too?
      ab_sym = :act_upon
    else
      ab_sym = ability.downcase.to_sym
    end

    group_ability = nil
    for ability_type, abilities in @abilities_config  
      for name, ability_def in abilities
        if name == ab_sym
          group_ability = ability_def
        end
      end
    end

    if group_ability
      # requires more than one ent
      # create new entity
      # TODO add p_id to command?
      p_id = 1
      # where to create this ent?
      x,y = nil
      if target.is_a? Array
        x = target[0]
        y = target[1]
      else
        x = target.tile_x
        y = target.tile_y
      end

      fire :create_ent, p_id, ab_sym, x, y, selected_ents
    else
      fire :sound_play, ab_sym
      selected_ents.each do |ent|
        # how to check for viable target?
        ent.send ab_sym, :target => target if ent.is? :able and ent.can? ab_sym
      end
    end
  end

  def execute_group_ability(ability_entity, composing_ents)
    ability_entity.automorph composing_ents
  end

end
