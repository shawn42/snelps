require 'button'
require 'checkbox'
class AbsoluteLayout < Rect

  attr_accessor :font_manager, :parent, :x, :y, :options, :w, :h

  def initialize(parent, font_manager, options = {})
    @parent = parent
    @x = options[:x] || 0
    @y = options[:y] || 0
    @w = options[:w] || 1024
    @h = options[:h] || 800
    @title = options[:title]
    @options = options
    @font_manager = font_manager
    @elements = []

    # TODO whats w/ the +1?
    if @title 

      on_drag = Proc.new do |x,y,event|
        pos = event.pos
        x2 = pos.first
        y2 = pos.last
        @x += x2-x
        @y += y2-y
      end
      title_bar = Button.new self, @title,
        {:w_pad=>5,:h_pad=>3,:w=>@w+1,:h=>20,
          :font_size=>10,:on_drag=>on_drag} 
      close_button = Button.new self, "X",
        {:w_pad=>5,:h_pad=>3,:w=>20,:h=>20,:x=>@w-20,
          :font_size=>10,:on_drag=>on_drag} do 
            #TODO this feels wrong?!
            @parent.close
          end
      @elements << title_bar 
      @elements << close_button
    end

  end

  def add(element, x, y)
    element.x = x
    element.y = y
    @elements << element
  end

  def remove(element)
    @elements.delete element
  end

  def draw(dest)
    dest.draw_box_s([@parent.x+@x, @parent.y+@y], [@parent.x+@x+@w, @parent.y+@y+@h], LIGHT_PURPLE)
    dest.draw_box([@parent.x+@x, @parent.y+@y], [@parent.x+@x+@w, @parent.y+@y+@h], LIGHT_GRAY)
    for el in @elements
      el.draw dest
    end
  end

  def update(time)
    for el in @elements
      el.update time
    end
  end

  def click(event)
    x = event.data[:x]
    y = event.data[:y]

    for el in @elements.reverse
      if el.hit_by? x, y
        el.click
        # only click on first thing found
        break
      end
    end
  end

  def mouse_motion(event)
    x = event.data[:x]
    y = event.data[:y]
    for el in @elements.reverse
      el.hover = false
    end

    for el in @elements.reverse
      if el.hit_by? x, y
        el.hover = true
        break
      end
    end
  end

  def mouse_dragging(start_x, start_y, event)
    for el in @elements.reverse
      if el.hit_by? start_x, start_y
        el.dragging start_x, start_y, event if el.respond_to? :dragging
        break
      end
    end
  end

  def mouse_drag(start_x, start_y, event)
    for el in @elements.reverse
      if el.hit_by? start_x, start_y
        el.drag start_x, start_y, event
        break
      end
    end
  end

  def key_up(event)
    for el in @elements.reverse
      if el.active
        el.key_up event
        break
      end
    end
  end

end
