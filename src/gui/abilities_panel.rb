# shows the player what abilities are available, based on the currently
# selected entities.
class AbilitiesPanel

  attr_accessor :x,:y,:w,:h,:label,:image,:parent,:hover,:options,:active
  def initialize(parent, options = {}, &block) 
    @options = options
    @abilities = options[:abilities]
    @x = options[:x] || 0
    @y = options[:y] || 0
    @w = options[:w]
    @h = options[:h]
    @font_size = options[:font_size] || 30
    @w_pad = options[:w_pad] || 40
    @h_pad = options[:h_pad] || 40
    @click_callback = options[:on_click]
    @click_callback = block if block_given?

    @drag_callback = options[:on_drag]

    # default padding is 10px
    @w = 2 * @w_pad unless @w
    @h = 2 * @h_pad unless @h
    @parent = parent
    @font_manager = @parent.font_manager
  end

  def set_padding(w_pad,h_pad)
    @w_pad = w_pad
    @h_pad = h_pad
    render
  end

  def render()
    text_image = @font_manager.render :excalibur, @font_size, @abilities, true, LIGHT_GRAY
    @w = text_image.size[0] + 2 * @w_pad unless @options[:w]
    @h = text_image.size[1] + 2 * @h_pad unless @options[:h]

    @image = Surface.new [@w,@h]
    text_image.blit @image, [@w_pad,@h_pad]
    @image.draw_box [0, 0], [@w-1, @h-1], LIGHT_GRAY

    @hover_image = Surface.new [@w,@h]
    @hover_image.fill PURPLE
    text_image.blit @hover_image, [@w_pad,@h_pad]
    @hover_image.draw_box [0, 0], [@w-1, @h-1], LIGHT_GRAY
  end

  def draw(dest)
    render if @image.nil?
    if @hover
      @hover_image.blit dest, [@parent.x+@x,@parent.y+@y]
    else
      @image.blit dest, [@parent.x+@x,@parent.y+@y]
    end
  end

  def update(time)
    # needed if any element wants to animate or whatever
  end

  def hit_by?(x,y)
    x >= @parent.x+@x and x <= @parent.x+@x + @w and y >= @parent.y+@y and y <= @parent.y+@y + @h
  end
  
  def click()
    @click_callback.call self if @click_callback
  end

  def key_up(event)
  end

  def drag(x,y,event)
    @drag_callback.call self, x, y, event if @drag_callback
  end
end
