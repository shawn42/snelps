
class MiniMap
  include Sprites::Sprite

  # update the mini map once per 2 seconds
  MINI_MAP_UPDATE_TIME = 2000
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

