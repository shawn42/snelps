# represents a game map
# this is a test commit
class Map
  def initialize(args = {})
    width = args[:width].nil? ? 6 : args[:width]
    height = args[:height].nil? ? 6 : args[:height]
    # nubmer of pixels of each tile
    tile_size = args[:tile_size].nil? ? 6 : args[:width]
    @internal_map = Array.new(width, Array.new(height))
  end

  def load()
  end
  
  def [](x,y)
  end
end
