require 'rubygoo'

# handles displaying the mouse in campaign mode
class EditorMouseView < Rubygoo::Widget
  attr_accessor :cursor
  def initialize(opts)
    @mouse = opts[:mouse]
    
    #TODO change this to come from theme props
    @pointer = opts[:resource_manager].load_image 'brush3.png'
    super opts
  end

  def mouse_motion(event)
    @x = event.data[:x]
    @y = event.data[:y]
  end

  def draw(dest)
    if @cursor
      off_x = @x - @cursor.size[0]/2
      off_y = @y - @cursor.size[1]/2
      dest.draw_image(@cursor, off_x, off_y)
    end
    dest.draw_image(@pointer, @x-16, @y-16)
  end
end
