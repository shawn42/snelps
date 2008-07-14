class ServerEntity
  attr_accessor :x, :y, :entity_type, :player
  def initialize(entity_type, x, y, player)
    @entity_type = entity_type
    @x = x
    @y = y
    @player = player
  end
end
