# EntitySelection represents a user selected list of enities.  These can be
# saved for later for shortcut mapping.
class EntitySelection
  attr_accessor :entities

  # creates an entity selection with an array of entities or a hash of {ent_id => ent}.
  def initialize(ents = nil)
    @entities = {}
    if ents
      if ents.is_a? Hash
        for ent in ents.values
          add_entity ent
        end
      elsif ents.is_a? Array
        for ent in ents
          add_entity ent
        end
      end
    end
  end

  # adds an entity to the selection
  def add_entity(ent)
    @entities[ent.server_id] = ent
    ent.select
  end

  def <<(ent)
    add_entity ent
  end

  # removes an entity from the selection
  def remove_entity(ent)
    @entities.delete(ent.server_id).deselect
  end

  def >>(ent)
    remove_entity ent
  end

  def clear()
    for ent_id in @entities.keys
      @entities.delete(ent_id).deselect
    end
  end

  # marks all children of the selection selected.
  def select()
    for ent in @entities.values
      ent.select
    end
  end

  # marks all children of the selection deselected.
  def deselect()
    for ent in @entities.values
      ent.deselect
    end
  end

end
