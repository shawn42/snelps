class ServerUnit
  attr_accessor :x, :y, :entity_type
  def initialize(entity_type, x, y)
    @entity_type = entity_type
    @x = x
    @y = y
  end
end
