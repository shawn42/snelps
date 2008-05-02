class CheckBox

  attr_accessor :x,:y,:w,:h,:label,:image,:parent,:hover,:options, :checked,:active
  def initialize(parent, label, options = {}, &block) 
    @options = options
    @checked = options[:checked] || false
    @label = label
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
    text_image = @font_manager.render :excalibur, @font_size, @label, true, LIGHT_GRAY
    @w = text_image.size[0] + 2 * @w_pad unless @options[:w]
    @h = text_image.size[1] + 2 * @h_pad unless @options[:h]

    box_size = 25
    @w += box_size * 2

    @image = Surface.new [@w,@h]
    text_image.blit @image, [@w_pad,@h_pad]

    @check_x1 = text_image.size[0] + @w_pad + box_size
    @check_x2 = text_image.size[0] + @w_pad + box_size * 2 - 1
    @check_y1 = @w_pad
    @check_y2 = @w_pad + box_size
    @image.draw_box [@check_x1, @check_y1], [@check_x2, @check_y2], LIGHT_GRAY

    @hover_image = Surface.new [@w,@h]
    @hover_image.fill PURPLE
    text_image.blit @hover_image, [@w_pad,@h_pad]

    @hover_image.draw_box [@check_x1, @check_y1], [@check_x2, @check_y2], LIGHT_GRAY

    @check_image = @font_manager.render :excalibur, @font_size, "X", true, LIGHT_GRAY
  end

  def draw(dest)
    render if @image.nil?
    if @hover
      @hover_image.blit dest, [@parent.x+@x,@parent.y+@y]
    else
      @image.blit dest, [@parent.x+@x,@parent.y+@y]
    end
    @check_image.blit dest, [@parent.x+@x+@check_x1,@parent.y+@y+@check_y1] if @checked

  end

  def update(time)
    # needed if any element wants to animate or whatever
  end

  def hit_by?(x,y)
    x >= @parent.x+@x and x <= @parent.x+@x + @w and y >= @parent.y+@y and y <= @parent.y+@y + @h
  end
  
  def checked?()
    @checked
  end

  def click()
    @checked = !@checked
    @click_callback.call self if @click_callback
  end

  def key_up(event)
  end

  def drag(x,y,event)
    @drag_callback.call self, x, y, event if @drag_callback
  end
end
