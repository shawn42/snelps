# class to convert world coords to screen coords and visa versa
class Viewport
  SCROLL_DELAY = 50
  ACTIVE_EDGE_WIDTH = 30
  attr_accessor :x_offset, :y_offset, :screen, :world_width, :world_height
  def initialize(screen)
    @x_offset = 0
    @y_offset = 0
    @vx = 0
    @vy = 0
    @screen = screen
    @last_update_time = 0
  end

  def set_map_size(width, height)
    @world_width = width
    @world_height = height
  end
  def size()
    @screen.size
  end

  def update(time)
    if @last_update_time > SCROLL_DELAY
      do_scroll
      @last_update_time = 0
    else
      @last_update_time += time
    end
  end

  # slide the viewport accordingly
  def do_scroll()
    @x_offset += @vx
    if max_right?
      @vx = 0
      @x_offset = @world_width - @screen.w
    elsif max_left?
      @vx = 0
      @x_offset = 0
    end

    @y_offset += @vy
    if max_up?
      @vy = 0
      @y_offset = 0
    elsif max_bottom?
      @vy = 0
      @y_offset = @world_height - @screen.h
    end
  end

  def max_left?
    return @x_offset <= 0
  end

  def max_up?
    return @y_offset <= 0
  end

  def max_right?
    return @x_offset >= (@world_width - @screen.w)
  end

  def max_bottom?
    return @y_offset >= (@world_height - @screen.h)
  end

  def scroll(event)
    pos = event.pos
    if pos[0] < ACTIVE_EDGE_WIDTH
      unless max_left?
        @vx = pos[0] - ACTIVE_EDGE_WIDTH
      end
    elsif pos[0] > @screen.w - ACTIVE_EDGE_WIDTH
      unless max_right?
        @vx = ACTIVE_EDGE_WIDTH - (@screen.w - pos[0])
      end
    else
      @vx = 0
    end
    if pos[1] < ACTIVE_EDGE_WIDTH
      unless max_up?
        @vy = pos[1] - ACTIVE_EDGE_WIDTH
      end
    elsif pos[1] > @screen.h - ACTIVE_EDGE_WIDTH
      unless max_bottom?
        @vy = ACTIVE_EDGE_WIDTH - (@screen.h - pos[0])
      end
    else
      @vy = 0
    end
  end

  # used when drawing
  def world_to_view(x,y)
    return x - @x_offset, y - @y_offset
  end

  # used for mouse
  def view_to_world(x,y)
    return x + @x_offset, y + @y_offset
  end

end
