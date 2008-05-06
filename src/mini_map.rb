require 'publisher'

class MiniMap
  extend Publisher

  can_fire :center_viewport

  # update the mini map once per 3 seconds
  MINI_MAP_UPDATE_TIME = 3000
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
    @image = @map_image
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
      @last_updated = 0
    else
      @last_updated += time
    end
  end

  def draw(destination)
    @image = @map_image
    @image.blit destination, [MINI_MAP_X,MINI_MAP_Y]
    view_x = MINI_MAP_X + @viewport.x_offset * SCALE
    view_y = MINI_MAP_Y + @viewport.y_offset * SCALE
    w = @viewport.width * SCALE
    h = @viewport.height * SCALE
#    destination.draw_box_s([view_x, view_y], [view_x + w, view_y + h], 
#      PURPLE)
    destination.draw_box([view_x, view_y], [view_x + w, view_y + h],
      PURPLE) 

    for ent in @entity_manager.entities
      entx = ent.x * SCALE + MINI_MAP_X
      enty = ent.y * SCALE + MINI_MAP_Y
      destination.draw_circle_s [entx.floor,enty.floor], 1, RED
    end
  end
end

