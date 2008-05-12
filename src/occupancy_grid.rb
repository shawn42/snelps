require 'narray'
class OccupancyGrid
  def initialize(width,height)
#    @mutex = Mutex.new
    @grid = NArray.object(width, height)
  end

  def occupy(x, y, entity)
#    @mutex.synchronize do
      if free? x, y
        @grid[x,y] = entity
      else
        raise "Occupancy Overlap"
      end
#    end
  end

  def leave(x, y)
#    @mutex.synchronize do
      @grid[x,y] = nil
#    end
  end

  def free?(x,y)
#    @mutex.synchronize do
      @grid[x,y].nil?
#    end
  end

  def occupied?(x,y)
    not free? x, y
  end

  def get_occupants(x,y,w,h,player_id=nil)
    occupants = {}
    rows = (x..x+w-1)
    cols = (y..y+h-1)
#    w.times do |r|
    for r in rows
      for c in cols
#      h.times do |c|
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
