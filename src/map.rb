require 'yaml'
require 'narray'
require 'publisher'
# represents a game map
# original map idea is to load/save as yaml
class Map
  extend Publisher

  can_fire :victory, :failure
  
  def to_yaml_properties()
    ['@width', '@height', '@tile_size', '@converted_tiles', '@half_tile_size']
  end

  attr_accessor :tile_size, :height, :width, :tile_images, :tiles,
    :converted_tiles, :viewport, :resource_manager, :half_tile_size,
    :background_image, :script, :entity_manager

  alias :w :width
  alias :h :height
  # TODO, this doesn't get called for maps loaded from file
#  def setup(args = {})
#    @entity_manager = args[:entity_manager]
#    @width = args[:width].nil? ? 6 : args[:width]
#    @height = args[:height].nil? ? 6 : args[:height]
#
#    # nubmer of pixels of each tile
#    @tile_size = args[:tile_size].nil? ? 32 : args[:tile_size]
#    @tiles = args[:tiles].nil? ? NArray.object(@width, @height) : args[:tiles]
#    @half_tile_size = (@tile_size / 2.0).floor
#    load_images
#  end

  def start_script()
    @script.start
  end

  def load_images()
    @tile_images = NArray.object @width, @height
    @width.times do |i|
      @height.times do |j|
        @tile_images[i,j] = 
          @resource_manager.load_image "terrain#{@tiles[i,j]}.png"
      end
    end
  end

  def pixel_height()
    @height * @tile_size
  end

  def pixel_width()
    @width * @tile_size
  end

  def self.load_from_file(resource_manager, map_name)
    map = resource_manager.load_map(map_name)
    map.resource_manager = resource_manager
    map.tiles = NArray.object(map.width, map.height)
    map.converted_tiles.each_with_index do |row,i|
      row.each_with_index do |col,j|
        map.tiles[i,j] = col
      end
    end
    map.load_images
    map
  end

  def save(file_name)
    @converted_tiles = @tiles.to_a
    @resource_manager.save_map self, file_name
  end

  def at(x,y)
    @tiles[x,y]
  end

  def set(x,y,val)
    @tiles[x,y] = val
  end

  # returns the tile x,y that the coord point falls in
  def coords_to_tiles(x, y)
    tiles = [(x / @tile_size).floor, (y / @tile_size).floor]
#    if tiles[1] > @height - 1 or tiles[0] > @width - 1
#      p "WTF: #{x},#{y}  => #{tiles[0]},#{tiles[1]}"
#    end
    tiles[0] = 0 if tiles[0] < 0
    tiles[0] = @width - 1 if tiles[0] > @width - 1
    tiles[1] = 0 if tiles[1] < 0
    tiles[1] = @height - 1 if tiles[1] > @height - 1
    tiles
  end

  # returns and array of [x,y] to the center of the tile
  def tiles_to_coords(tile_x, tile_y)
    [tile_x * @tile_size + @half_tile_size,
      tile_y * @tile_size + @half_tile_size]
  end

  def recreate_map_image()
    @background_image = Surface.new [pixel_width,pixel_height]
    @width.times do |i|
      @height.times do |j|
        x = i * @tile_size
        y = j * @tile_size
        @tile_images[i,j].blit @background_image, @viewport.world_to_view(x,y)
      end
    end
  end

  def update(time)
    @script.update time 
  end

  def draw_full(destination)
    recreate_map_image if @background_image.nil?
    @background_image.blit destination, @viewport.world_to_view(0,0)
  end

  def draw(destination)
    recreate_map_image if @background_image.nil?
#    @background_image.blit destination, @viewport.world_to_view(0,0)
    # draw only the visible?
    y_off = @viewport.screen_y_offset
    x_off = @viewport.screen_x_offset
    @background_image.blit destination, [0,0], 
      [@viewport.x_offset+x_off,@viewport.y_offset+y_off,@viewport.width,@viewport.height]
  end
end

