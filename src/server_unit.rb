class ServerUnit
  attr_accessor :x, :y, :unit_type
  def initialize(unit_type, x, y)
    @unit_type = unit_type
    @x = x
    @y = y
  end
end
