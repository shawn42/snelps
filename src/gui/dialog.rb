require 'absolute_layout'
class Dialog
  attr_accessor :parent, :font_manager, :layout, :size, :on_close, :x, :y
  
  def initialize(parent, *args)
    @parent = parent
    @font_manager = parent.font_manager
    @x = 0
    @y = 0
    setup *args
  end

  def setup()
    @layout = AbsoluteLayout.new self, @font_manager
  end

  def on_mouse_motion(event)
    @layout.mouse_motion(event)
  end

  def on_mouse_drag(start_x, start_y, event)
    @layout.mouse_drag(start_x, start_y, event)
  end

  def on_click(event)
    @layout.click(event)
  end

  def on_key_up(event)
    @layout.key_up(event)
  end

  def draw(destination)
    @layout.draw destination
  end
  
  def apply?()
    @apply
  end
  
  def apply()
    @apply = true
  end

  def close_callback()
    @on_close.call self if @on_close
  end

  def close()
    fire :destroy_modal_dialog, self
  end
  
  def on_network(event); end
  def update(time);end

end

