require 'publisher'

class MiniMap
  extend Publisher

  can_fire :center_viewport

  MINI_MAP_UPDATE_TIME = 200
  MINI_MAP_X = 850
  MINI_MAP_Y = 160
  SCALE = 0.08

  def initialize(map, viewport, entity_manager)
    @last_updated = 0
    @map = map
    @viewport = viewport
    @entity_manager = entity_manager

    surf = Surface.new [@map.pixel_width, @map.pixel_height]
    @map.draw surf
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
    pos = event.pos
    x_click = pos[0]
    y_click = pos[1]

    scaled_x = x_click - MINI_MAP_X
    scaled_y = y_click - MINI_MAP_Y
    
    x = scaled_x / SCALE + @viewport.screen_x_offset
    y = scaled_y / SCALE + @viewport.screen_y_offset
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

    x = SCALE * @viewport.x_offset
    y = SCALE * @viewport.y_offset
    @image.draw_box([x, y], [x+@w, y+@h], PURPLE) 

    for ent in @entity_manager.entities
      entx = ent.x * SCALE
      enty = ent.y * SCALE
      @image.draw_circle_s [entx.floor,enty.floor], 1, RED
    end
  end

  def draw(destination)
    @image.blit destination, [MINI_MAP_X,MINI_MAP_Y]
  end
end

