# represents a game map
# original map idea is to load/save as yaml
class Map
  def initialize(args = {})
    @width = args[:width].nil? ? 6 : args[:width]
    @height = args[:height].nil? ? 6 : args[:height]
    # nubmer of pixels of each tile
    @tile_size = args[:tile_size].nil? ? 6 : args[:width]
    @tiles = Array.new(width, Array.new(height))
  end

  def load(map_name)
  end
  
  def [](x,y)
  end
end
