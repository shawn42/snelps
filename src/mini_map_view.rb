require 'rubygoo'
class MiniMapView < Rubygoo::Widget

  attr_writer :mini_map

  def draw(adapter)
    adapter.draw_image @mini_map.image, @x, @y
  end

  def mini_map=(mm)
    @w,@h = mm.image.size
    update_rect
    @mini_map = mm
  end

  def mouse_up(event)
    x = event.data[:x] - @x
    y = event.data[:y] - @y
    @mini_map.handle_mouse_click x, y
  end

  def mouse_dragging(event)
    x = event.data[:x] - @x
    y = event.data[:y] - @y
    @mini_map.handle_mouse_dragging x, y
  end

  def update(time)
    @mini_map.update time
  end
end
