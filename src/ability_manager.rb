$: << "../lib"
require 'yaml'

class AbilityManager
  constructor :resource_manager
  
  def setup()
    @abilities_config = @resource_manager.load_gameplay_config "abilities_defs"
  end

  def abilities_for(entity_selection)
    return [] if entity_selection.nil? 


    types = {:entity => 0}
    for ent in entity_selection.entities.values
      types[ent.entity_type] = 0 if types[ent.entity_type].nil?
      types[ent.entity_type] += 1
      types[:entity] += 1
    end

    allowed_abilities = []
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
end
