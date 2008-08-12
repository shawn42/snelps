# handles all the mouse events and mouse-state tracking, such as drags
class MouseManager
  extend Publisher
  can_fire :mouse_click, :mouse_drag, :mouse_motion, :mouse_dragging

  LEFT_BUTTON = 1
  MIDDLE_BUTTON = 2
  RIGHT_BUTTON = 3
  
  constructor :viewport
  def setup
    @viewport.when :screen_scroll do |delta|
      screen_scrolled delta[0], delta[1]
    end
  end

  def draw(screen)
    if @dragging
      screen.draw_box([@start_x, @start_y], [@x, @y], LIGHT_GREEN)
      screen.draw_box_s([@start_x, @start_y], [@x, @y], GREEN_HALF_ALPHA)
    end
  end

  def mouse_motion(event)
    @x = event.pos.first
    @y = event.pos.last
    if @dragging
      fire :mouse_dragging, @x, @y, event
    end
    fire :mouse_motion, event
  end
  
  def mouse_down(event)
    if event.button = LEFT_BUTTON
      pos = event.pos
      @start_x = pos.first
      @start_y = pos.last
      @dragging = true
    end
  end

  def mouse_up(event)
    if event.button = LEFT_BUTTON
      @dragging = false
      pos = event.pos

      if @start_x == pos.first and @start_y == pos.last
        #clicked
#        puts "clicked"
        fire :mouse_click, event
      else
        # drag
#        puts "drag received"
        fire :mouse_drag, @start_x, @start_y, event
      end
    end
  end

  # when the user scrolls the screen, the mouse_managers anchors need to
  # stay the same for drags
  def screen_scrolled(delta_x, delta_y)
    @start_x ||= 0
    @start_y ||= 0
    @start_x += delta_x
    @start_y += delta_y
  end
end
