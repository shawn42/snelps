module Positionable

  def self.included(target)
    target.add_update_listener :update_positionable
    target.add_setup_listener :setup_positionable
  end

  attr_accessor :tile_x, :tile_y
  def x();@rect.centerx;end
  def y();@rect.centery;end
  def w();@rect.w;end
  def h();@rect.h;end

  def setup_positionable(args)
    @map = args[:map]
    tile_size = @map.tile_size
    @rect = Rect.new args[:x],args[:y],tile_size,tile_size

    @tile_x, @tile_y = @map.coords_to_tiles x, y
    @grid = args[:occupancy_grid]
    @grid.occupy @tile_x, @tile_y
  end

  def update_positionable(time)
  end

  def hit_by?(x, y)
    world_x, world_y = @viewport.view_to_world(x, y)
    @rect.collide_point? world_x, world_y
  end

  def in?(rect)
    world_x, world_y = @viewport.view_to_world(rect.x, rect.y)
    world_rect = Rect.new world_x, world_y, rect.w, rect.h
    @rect.collide_rect? world_rect
  end

  def in_tile?(pos)
    world_x, world_y = @map.tiles_to_coords(pos[0],pos[1])
    tile_size = @map.tile_size
    world_rect = Rect.new world_x, world_y, tile_size, tile_size
    @rect.collide_rect? world_rect
  end
end
