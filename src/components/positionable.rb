module Positionable

  def self.included(target)
    target.add_setup_listener :setup_positionable
  end

  attr_accessor :tile_x, :tile_y
  def x();@rect.centerx;end
  def y();@rect.centery;end
  def w();@rect.w;end
  def h();@rect.h;end

  def setup_positionable(args)
    @map = args[:map]
    @grid = args[:occupancy_grid]
    tile_size = @map.tile_size
    half_tile_size = @map.half_tile_size

    # TODO update for many square occupiers
    @rect = Rect.new args[:x]-half_tile_size,args[:y]-half_tile_size,tile_size,tile_size

    @tile_x, @tile_y = @map.coords_to_tiles x, y
#    position_at @tile_x, @tile_y
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
    # TODO why does setup use diff coords
    world_rect = Rect.new world_x, world_y, tile_size, tile_size
    @rect.collide_rect? world_rect
  end

  # move the entity to that location on the occupancy grid
  # (including the extra size for enitites that are greater than
  # 1x1).
  def position_at(new_tile_x, new_tile_y)
    @tile_x = new_tile_x
    @tile_y = new_tile_y

    if respond_to? :size and self.size
      size[0].times do |col|
        size[1].times do |row|
          @grid.occupy @tile_x+row, @tile_y+col, self
        end
      end
    else
      @grid.occupy @tile_x, @tile_y, self
    end
  end

  # remove the entity from that location on the occupancy grid
  # (including the extra size for enitites that are greater than
  # 1x1).
  def remove_from(new_tile_x, new_tile_y)
    @tile_x = new_tile_x
    @tile_y = new_tile_y

    if respond_to? :size and self.size
      size[0].times do |col|
        size[1].times do |row|
          @grid.leave @tile_x+row, @tile_y+col
        end
      end
    else
      @grid.leave @tile_x, @tile_y
    end
  end

  # not only checks the single placement square, but checks any
  # other squares the entity would occupy
  def can_be_placed_at(new_tile_x, new_tile_y)
  end
end
