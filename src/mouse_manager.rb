require 'rubygoo'
# handles all the mouse events and mouse-state tracking, such as drags
class MouseManager < Rubygoo::Widget
  extend Publisher
  can_fire :mouse_click, :mouse_drag, :mouse_motion, :mouse_dragging

  LEFT_BUTTON = 1
  MIDDLE_BUTTON = 2
  RIGHT_BUTTON = 3

  attr_accessor :start_x, :start_y, :x, :y
  
  constructor :viewport, :resource_manager
  def setup
    @x = 0
    @y = 0
    @viewport.when :screen_scroll do |delta|
      screen_scrolled delta[0], delta[1]
    end
  end

  def dragging?()
    @dragging
  end

  def mouse_motion(event)
    @x = event.data[:x]
    @y = event.data[:y]
    if @dragging
      fire :mouse_dragging, @x, @y, event
    end
    fire :mouse_motion, event
  end
  
  def mouse_down(event)
    if event.data[:button] == LEFT_BUTTON
      @start_x = event.data[:x]
      @start_y = event.data[:y]
      @dragging = true
    end
  end

  def mouse_up(event)
    if event.data[:button] == LEFT_BUTTON
      @dragging = false

      if @start_x == event.data[:x] and @start_y == event.data[:y]
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
