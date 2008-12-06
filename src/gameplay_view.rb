require 'rubygoo'
class GameplayView < Rubygoo::Widget

  attr_writer :map, :view_screen, :entity_manager, :fog

  def draw(adapter)
    @map.draw @view_screen
    @entity_manager.draw @view_screen
    @fog.draw @view_screen
    adapter.draw_image @view_screen, @x, @y
  end

  def mouse_up(event)
    if @mini_map and @mini_map.hit_by? event.data[:x], event.data[:y]
      @mini_map.handle_mouse_click event
    else
      @entity_manager.handle_mouse_click event
    end
  end

  def mouse_drag(event)
    @entity_manager.handle_mouse_drag event
  end

  def update(time)
    @map.update time
    @entity_manager.update time
    @map.update time unless @map.nil?
    @viewport.update time unless @viewport.nil?
    @entity_manager.update time unless @entity_manager.nil?
#    @abilities_panel.update time unless @abilities_panel.nil?

  end

end
