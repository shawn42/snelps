require 'rubygoo'
class EditorView < Rubygoo::Widget

  # Health box sizes
  HB_HEIGHT = 2
  HB_WIDTH = 20

  attr_writer :map, :map_editor, :viewport
  def initialize(opts)
    super opts
    @green = Rubygoo::GooColor.color :Green
    @chartreuse = Rubygoo::GooColor.color :Chartreuse
    @red = Rubygoo::GooColor.color :Red
  end

  def viewport=(vp)
    @w = vp.width
    @h = vp.height
    @viewport = vp
    update_rect
  end

  def draw(adapter)
    # TODO change all of these to be rubygoo safe
    # TODO should I pull the map image creation up to here?
    @map.recreate_map_image unless @map.background_image

    adapter.draw_partial_image @map.background_image, @x,@y, @viewport.x_offset,@viewport.y_offset,@viewport.width,@viewport.height

  end

  def mouse_up(event)
    if @mini_map and @mini_map.hit_by? event.data[:x], event.data[:y]
      @mini_map.handle_mouse_click event
    else
      @map_editor.handle_mouse_click event
    end
  end

  def mouse_drag(event)
    @map_editor.handle_mouse_drag event
  end

  def update(time)
    @map.update time unless @map.nil?
    @viewport.update time unless @viewport.nil?
    @map_editor.update time unless @map_editor.nil?
  end

end
