# MapScript is extended by map definitions and has all the allowed API for map
require 'publisher'
class MapScript
  extend Publisher
  can_fire :create_entity, :victory, :defeat, :create_player

  attr_accessor :map
  def initialize(script_text)
    @script_text = script_text
    @last_updated = 0
  end

  def start()
    instance_eval @script_text
  end

  def get_occupants_at(x,y,w=1,h=1,player=nil)
    # horrible hack just to see if it works, then i will fix the object
    # hierarchy 
    @map.instance_variable_get("@entity_manager").get_occupants_at(x, y, w, h, player)
  end

  def on(*args, &blk)
    @map.instance_variable_get("@entity_manager").on(*args,&blk)
  end

  # create a player
  def create_player(snelp,type=nil)
    fire :create_player, snelp, type 
  end

  # creates an entity of type, owned by player, at tile_x,tile_y
  def create_entity(player,ent_type,tile_x,tile_y)
    fire :create_entity,player,ent_type,tile_x,tile_y
  end

end
