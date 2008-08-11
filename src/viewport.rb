# class to convert world coords to screen coords and visa versa
class Viewport
  extend Publisher
  can_fire :screen_scroll

  SCROLL_DELAY = 40
  ACTIVE_EDGE_WIDTH = 35
  SCROLL_SPEED = 3#0.7
  JUMP_DISTANCE = 32*6#0.7
  attr_accessor :x_offset, :y_offset, :world_width, :world_height,
    :screen_x_offset, :screen_y_offset, :width, :height

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

    # used for scroll detection
    @ll_view_line = @screen_x_offset
    @lr_view_line = @screen_x_offset + ACTIVE_EDGE_WIDTH
    @rl_view_line = @screen_x_offset + @width - ACTIVE_EDGE_WIDTH
    @rr_view_line = @screen_x_offset + @width
    @tt_view_line = @screen_y_offset
    @tb_view_line = @screen_y_offset + ACTIVE_EDGE_WIDTH
    @bt_view_line = @screen_y_offset + @height - ACTIVE_EDGE_WIDTH
    @bb_view_line = @screen_y_offset + @height
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
    @y_offset = [y - @height/2, 0].max
    @x_offset = [x - @width/2, 0].max
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

  def scroll(event)
    pos = event.pos
    mouse_x = pos[0]
    mouse_y = pos[1]

    if @ll_view_line < mouse_x and mouse_x < @lr_view_line
      unless max_left?
        @vx = (mouse_x - @screen_x_offset - ACTIVE_EDGE_WIDTH) * SCROLL_SPEED
      end
    elsif @rl_view_line < mouse_x and mouse_x < @rr_view_line
      unless max_right?
        @vx = (ACTIVE_EDGE_WIDTH - (@width - mouse_x + @screen_x_offset)) * SCROLL_SPEED
      end
    else
      @vx = 0
    end

    if @tb_view_line > mouse_y and mouse_y > @tt_view_line
      unless max_up?
        @vy = (mouse_y - @screen_y_offset - ACTIVE_EDGE_WIDTH) * SCROLL_SPEED
      end
    elsif @bb_view_line > mouse_y and mouse_y > @bt_view_line
      unless max_bottom?
        @vy = (ACTIVE_EDGE_WIDTH - (@height - mouse_y + @screen_y_offset)) * SCROLL_SPEED
      end
    else
      @vy = 0
    end
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
