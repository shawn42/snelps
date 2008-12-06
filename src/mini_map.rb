require 'publisher'

class MiniMap
  extend Publisher

  can_fire :center_viewport

  MINI_MAP_UPDATE_TIME = 200
  MINI_MAP_X = 850
  MINI_MAP_Y = 150
  SCALE = 0.08

  attr_accessor :fog
  attr_reader :image

  def initialize(map, viewport, entity_manager)
    @last_updated = 0
    @map = map
    @viewport = viewport
    @entity_manager = entity_manager

    surf = Surface.new [@map.pixel_width, @map.pixel_height]
    @map.draw_full surf
    @map_image = surf.zoom [SCALE,SCALE], true

    @w = @viewport.width * SCALE
    @h = @viewport.height * SCALE
    render
    @rect = Rect.new(MINI_MAP_X,MINI_MAP_Y,*@image.size)
  end

  def hit_by?(x,y)
    @rect.collide_point? x, y
  end


  def handle_mouse_click(event)
    x, y = translate_event_coords event
    fire :center_viewport, x, y
  end

  def handle_mouse_dragging(event)
    x, y = translate_event_coords event
    fire :center_viewport, x, y
  end

  def update(time)
    if @last_updated > MINI_MAP_UPDATE_TIME
      render
      @last_updated = 0
    else
      @last_updated += time
    end
  end

  def render()
    @image = Surface.new(@map_image.size)
    @map_image.blit @image, [0,0]

    # hard code the player for now (they can only see where their
    # entities are
    for ent in @entity_manager.get_player_ents(1)
      entx = ent.x * SCALE
      enty = ent.y * SCALE
      @image.draw_circle_s [entx.floor,enty.floor], 1, RED
    end

    @fog.draw_minimap_fog @image if @fog

    x = SCALE * @viewport.x_offset
    y = SCALE * @viewport.y_offset
    @image.draw_box([x, y], [x+@w, y+@h], WHITE) 
  end
  
  protected
  def translate_event_coords(event)
    x_click = event.data[:x] + @viewport.screen_x_offset
    y_click = event.data[:y] + @viewport.screen_y_offset

    x = x_click / SCALE + @viewport.screen_x_offset
    y = y_click / SCALE + @viewport.screen_y_offset
    return x, y
  end
end

