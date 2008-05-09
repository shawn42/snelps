# MapScript is extended by map definitions and has all the allowed API for map
# designers to use. It is owned by the map instance that is loaded.
require 'publisher'
class MapScript
  extend Publisher
  can_fire :create_entity, :add_zone_listener

  def initialize(script_text)
    @script_text = script_text
  end

  def start()
    instance_eval @script_text
  end

  # creates an entity of type, owned by player, at tile_x,tile_y
  def create_entity(ent_type,player,tile_x,tile_y)
    fire :create_entity,ent_type,player,tile_x,tile_y
  end

  # watches for entities owned by player, entering zone x,y,w,h
  def add_zone_listener(player,tile_x,tile_y,tile_w,tile_h, &block)
    # TODO not sure how I want this method to work
    fire :add_zone_listener,player,tile_x,tile_y,tile_w,tile_h,block
  end

end
