# class to convert world coords to screen coords and visa versa
class Viewport
  attr_accessor :x_offset, :y_offset
  def initialize()
    @x_offset = 0
    @y_offset = 0
  end

  # used when drawing
  def world_to_view(x,y)
    x - @x_offset, y - @y_offset
  end

  # used for mouse
  def view_to_world(x,y)
    x + @x_offset, y + @y_offset
  end

end
