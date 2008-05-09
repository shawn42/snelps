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

  def get_occupants(x,y,w,h)
    occupants = {}
    rows = (x..x+w)
    cols = (y..y+h)
#    w.times do |r|
    for r in rows
      for c in cols
#      h.times do |c|
        ent = @grid[r,c]
        occupants[ent.server_id] = ent unless ent.nil?
      end
    end
    occupants.values
  end

end
