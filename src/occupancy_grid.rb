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
    @grid[x,y].nil?
  end

  def occupied?(x,y)
    not free? x, y
  end

  def get_occupants(x,y,w=1,h=1,player_id=nil)
    occupants = {}
    rows = (x..x+w-1)
    cols = (y..y+h-1)
    for r in rows
      for c in cols
        ent = @grid[r,c]
        unless ent.nil? 
          if player_id.nil? or ent.player_id == player_id
            occupants[ent.server_id] = ent 
          end
        end
      end
    end
    occupants.values
  end

end
