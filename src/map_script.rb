# MapScript is extended by map definitions and has all the allowed API for map
# designers to use. It is owned by the map instance that is loaded.
require 'publisher'
class MapScript
  extend Publisher
  can_fire :create_entity, :victory

  #check all triggers this often (ms)
  TRIGGER_UPDATE_TIME = 2000

  attr_accessor :map
  def initialize(script_text)
    @script_text = script_text
    @last_updated = 0
    @triggers = []
  end

  def start()
    instance_eval @script_text
  end

  def get_occupants_at(x,y,w,h,player=nil)
    # horrible hack just to see if it works, then i will fix the object
    # hierarchy 
    grids = @map.instance_variable_get("@entity_manager").instance_variable_get("@occupancy_grids")
    occs = []
    for z,grid in grids
      occs << grid.get_occupants(x, y, w, h, 0)
      occs.flatten!
    end
    occs
  end

  def update(time)
    if @last_updated > TRIGGER_UPDATE_TIME
      update_triggers time
      @last_updated = 0
    else
      @last_updated += time
    end
  end

  def update_triggers(time)
    for trig in @triggers
      trig.call
    end
  end

  # creates an entity of type, owned by player, at tile_x,tile_y
  def create_entity(ent_type,player,tile_x,tile_y)
    fire :create_entity,ent_type,player,tile_x,tile_y
  end

  def add_trigger(&block)
    @triggers << block
  end

end
