require 'yaml'
require 'narray'
require 'publisher'
# represents a game map
# original map idea is to load/save as yaml
class Map
  extend Publisher

  def to_yaml_properties()
    ['@width', '@height', '@tile_size', '@converted_tiles', '@half_tile_size']
  end

  attr_accessor :tile_size, :height, :width, :tile_images, :tiles,
    :converted_tiles, :viewport, :resource_manager, :half_tile_size,
    :background_image, :script, :entity_manager, :tile_config

  alias :w :width
  alias :h :height

  def start_script()
    @script.start if @script
  end

  def load_images()
    @tile_config ||= @resource_manager.load_gameplay_config 'terrain_defs'
    @tile_images = NArray.object @width, @height
    @width.times do |i|
      @height.times do |j|
        tile_id = @tiles[i,j]
        @tile_images[i,j] = tile_image_for tile_id
      end
    end
  end

  def tile_image_for(tile_id)
    for type, config in @tile_config
      range = (config[:first]..config[:last])
      if range.include? tile_id
        tile_type = type
        tile_conf = config
          # TODO clean this up TERRAIN_DIR?
        return @resource_manager.load_image(File.join("terrain","#{tile_conf[:prefix]}#{tile_id}#{tile_conf[:suffix]}"))
      end
    end
    raise "unknown tile id: #{tile_id} in map" if tile_type.nil?
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
        map.tiles[j,i] = col
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
    @script.update time if @update
  end

  def draw_full(destination)
    recreate_map_image if @background_image.nil?
    @background_image.blit destination, @viewport.world_to_view(0,0)
  end

end

