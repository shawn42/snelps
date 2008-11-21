$: << "../lib"
require 'yaml'
require 'publisher'

class AbilityManager
  extend Publisher

  can_fire :sound_play

  constructor :resource_manager
  
  def setup()
    @abilities_config = @resource_manager.load_gameplay_config "abilities_defs"
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
      ab_sym = :move
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
      p "GROUP"
      # create new entity
    else
      fire :sound_play, ab_sym
      selected_ents.each do |ent|
        # how to check for viable target?
        ent.send ab_sym, :target => target if ent.is? :able and ent.can? ab_sym
      end
    end
  end

end
