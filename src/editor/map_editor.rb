require 'publisher'

class MapEditor
  extend Publisher
  attr_accessor :map, :current_tile_stamp

  constructor :sound_manager, :input_manager, :viewport
  
  def setup()
    
  end

  def handle_key_up(event)
    case event.data[:key]
    when K_S
      @map.save "temp"
    end
  end

  def handle_mouse_click(event)
    return if @current_tile_stamp.nil?
    x = event.data[:x]
    y = event.data[:y]
    world_x, world_y = @viewport.view_to_world(x, y)

    tile_x,tile_y = 
      @map.coords_to_tiles(world_x,world_y)
    @map.tiles[tile_x,tile_y] = @current_tile_stamp 

    #@map.load_images
    set_tile tile_x, tile_y, @current_tile_stamp

    # TODO make map configurable to not used a cached bg image?
    @map.recreate_map_image
  end

  def set_tile(tile_x,tile_y,tile_id)
    tile_type = nil
    tile_conf = nil
    for type, config in @map.tile_config
      range = (config[:first]..config[:last])
      if range.include? tile_id
        tile_type = type
        tile_conf = config
        break
      end
    end
    @map.tile_images[tile_x,tile_y] = 
      @map.resource_manager.load_image File.join("terrain","#{tile_conf[:prefix]}#{tile_id}#{tile_conf[:suffix]}")
  end

  def handle_mouse_drag(event)
    x = event.data[:start_x]
    y = event.data[:start_y]
    new_x = event.data[:x]
    new_y = event.data[:y]
		x_array = [x, new_x].sort
		y_array = [y, new_y].sort

#    select_in x_array.first,y_array.first, x_array.last -
#                     x_array.first ,y_array.last - y_array.first
  end

  def update(time)
  end
  
end