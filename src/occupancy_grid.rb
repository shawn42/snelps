require 'publisher'
require 'narray'
class OccupancyGrid
  extend Publisher

  can_fire :occupancy_change

  def initialize(width,height)
    @grid = NArray.object(width, height)
  end

  def occupy(x, y, entity)
      if free? x, y
        fire :occupancy_change, :occupy, entity
        @grid[x,y] = entity
      else
        raise "Occupancy Overlap"
      end
  end

  def leave(x, y)
    fire :occupancy_change, :leave, @grid[x,y]
    @grid[x,y] = nil
  end

  def free?(x,y)
    !@grid[x,y]
  end

  def occupied?(x,y)
    not free? x, y
  end

  # TODO PERF break out into two methods
  def get_occupants_by_player(x,y,w,h,player_id)
    occupants = {}

    # TODO PERF only update these on viewport scroll
    rows = (x..x+w-1)
    cols = (y..y+h-1)
    for r in rows
      for c in cols
        ent = @grid[r,c]
        if ent and ent.player_id == player_id
          occupants[ent.server_id] = ent 
        end
      end
    end
    occupants.values
  end

  def get_occupants(x,y,w=1,h=1)
    occupants = {}

    # TODO PERF only update these on viewport scroll
    rows = (x..x+w-1)
    cols = (y..y+h-1)
    for r in rows
      for c in cols
        ent = @grid[r,c]
        occupants[ent.server_id] = ent if ent
      end
    end
    occupants.values
  end

end
