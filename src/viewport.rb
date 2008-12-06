# class to convert world coords to screen coords and visa versa
class Viewport
  extend Publisher
  can_fire :screen_scroll

  SCROLL_DELAY = 30
  ACTIVE_EDGE_WIDTH = 35
  SCROLL_SPEED = 3#0.7
  JUMP_DISTANCE = 32*6#0.7
  attr_accessor :x_offset, :y_offset, :world_width, :world_height,
    :screen_x_offset, :screen_y_offset, :width, :height, :vx, :vy

  constructor :snelps_screen, :config_manager

  def setup()
    @screen_x_offset = @config_manager[:viewport_screen_x]
    @screen_y_offset = @config_manager[:viewport_screen_y]
    @width = @config_manager[:viewport_width]
    @height = @config_manager[:viewport_height]
    @x_offset = 0
    @y_offset = 0
    @vx = 0
    @vy = 0
    @last_update_time = 0
  end

  def set_map_size(width, height)
    @world_width = width
    @world_height = height
  end

  def size()
    @snelps_screen.size
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
  # TODO recheck these, with new gui stuff
  def do_scroll()
    orig_x_offset = @x_offset
    orig_y_offset = @y_offset
    @x_offset += @vx
    if max_right?
      @vx = 0
      @x_offset = @world_width - @width
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
      @y_offset = @world_height - @height
    end

    fire :screen_scroll, [orig_x_offset-@x_offset,orig_y_offset-@y_offset]
  end

  def center_to(x, y)
    new_y = [y - @height/2, 0].max
    new_x = [x - @width/2, 0].max
    @y_offset = [new_y, @world_width - @height].min
    @x_offset = [new_x, @world_width - @width].min
  end
  
  def max_left?
    return @x_offset <= 0
  end

  def max_up?
    return @y_offset <= 0
  end

  def max_right?
    return @x_offset >= (@world_width - @width)
  end

  def max_bottom?
    return @y_offset >= (@world_height - @height)
  end

  def jump(dir)
    amount = JUMP_DISTANCE
    case dir
    when :up
      @vy = -amount
    when :down
      @vy = amount
    when :left
      @vx = -amount
    when :right
      @vx = amount
    end
    
    orig_x_offset = @x_offset
    orig_y_offset = @y_offset
    @x_offset += @vx
    if max_right?
      @vx = 0
      @x_offset = @world_width - @width
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
      @y_offset = @world_height - @height
    end

    @vy = 0
    @vx = 0

    fire :screen_scroll, [orig_x_offset-@x_offset,orig_y_offset-@y_offset]
  end

  # used when drawing, drawing is done on a surface not the screen
  def world_to_view(x,y)
    return x - @x_offset, y - @y_offset
  end

  # used for mouse
  def view_to_world(x,y)
    return x + @x_offset - @screen_x_offset, y + @y_offset - @screen_y_offset
  end

end
