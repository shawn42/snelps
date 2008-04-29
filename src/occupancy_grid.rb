require 'narray'
class OccupancyGrid
  def initialize(width,height)
#    @mutex = Mutex.new
    @grid = NArray.object(width, height)
  end

  def occupy(x, y)
#    @mutex.synchronize do
      @grid[x,y] = 1
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

end
