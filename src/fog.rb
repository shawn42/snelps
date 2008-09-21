require 'narray'
require 'colors'
include Colors

# blocks the players view from things they haven't discovered
# TODO change this to modify some kind of masking image instead of maintaining this; said mask could also be used for the minimap
class Fog
  def initialize(map,entity_manager,viewport,resource_manager)
    @entity_manager = entity_manager
    @viewport = viewport
    @resource_manager = resource_manager
    @image = @resource_manager.load_image 'fog.png'
    @map = map
    @tile_size = @map.tile_size

    @grid = NArray.object(@map.width, @map.height)

    @entity_manager.when :occupancy_grid_created do |grid, z|
      grid.when :occupancy_change do |operation, occupant, tx, ty|
        # TODO un-hardcode the player id
        if occupant.player_id == 1
          # TODO why is occupy, leave messed up?
#          if operation == :occupy 
            # TODO fix this for the visibility range
            for x in ([tx-1,0].max..[tx+1,@map.width-1].min)
              for y in ([ty-1,0].max..[ty+1,@map.height-1].min)
                @grid[x,y] = :visible
              end
            end
#          end
        end
      end
    end
  end

  def draw(screen)
    rows = @entity_manager.viewable_rows
    cols = @entity_manager.viewable_cols
    x_soff = @viewport.screen_x_offset
    y_soff = @viewport.screen_y_offset
    x_off = @viewport.x_offset
    y_off = @viewport.y_offset

    for c in cols
      for r in rows
        unless @grid[r,c] == :visible
          x = (r)*@tile_size + x_soff - x_off
          y = (c)*@tile_size + y_soff - y_off
          @image.blit screen, [x,y]
#          screen.draw_box_s [x,y],[x+@tile_size,y+@tile_size], BLACK
        end
      end
    end
  end
end
