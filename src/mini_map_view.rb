require 'rubygoo'
class MiniMapView < Rubygoo::Widget

  attr_writer :mini_map

  def draw(adapter)
    adapter.draw_image @mini_map.image, @x, @y
  end

  def mouse_up(event)
    @mini_map.handle_mouse_click event
  end

  def mouse_dragging(event)
    @mini_map.handle_mouse_dragging event
  end

  def update(time)
    @mini_map.update time
  end
end
