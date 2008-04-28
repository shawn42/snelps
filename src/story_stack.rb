# StoryStack is a class that shows story images w/ text on them.
# I'd like to add fancy transitions here someday (think apple screen
# saver)
class StoryStack

  attr_accessor :x,:y,:w,:h,:image,:parent,:options,:hover,:active
  def initialize(parent, stack, options = {}, &block) 
    @options = options
    @x = options[:x] || 0
    @y = options[:y] || 0
    @w = options[:w] || parent.w 
    @h = options[:h] || parent.h
    @font_size = options[:font_size] || 30
    @parent = parent
    @font_manager = @parent.font_manager
    @the_end_callback = block

    @active = true
    @stack = stack
    if @stack.nil? or @stack.empty?
      story_finished 
    else
      next_frame
    end
  end

  def render()
    # TODO load image from @frame[1]
    text_image = @font_manager.render :excalibur, @font_size, @frame[0], true, LIGHT_GRAY
    @image = Surface.new [@w,@h]
    @image.fill PURPLE
    text_image.blit @image, [0,0]
    @image.draw_box [0, 0], [@w-1, @h-1], LIGHT_GRAY
  end

  def draw(dest)
    @image.blit dest, [@parent.x+@x,@parent.y+@y]
  end

  def update(time)
    # needed if any element wants to animate or whatever
  end

  def hit_by?(x,y)
    x >= @parent.x+@x and x <= @parent.x+@x + @w and y >= @parent.y+@y and y <= @parent.y+@y + @h
  end
  
  def key_up(event)
    next_frame
  end
  
  def next_frame()
    @frame = @stack.shift
    # TODO this is wrong.. shouldn't be closing our parent
    # maybe the parent should subscribe to the layout?
    if @frame.nil?
      story_finished
    else
      render
    end
  end

  def story_finished()
    @the_end_callback.call
  end

  def click()
    next_frame
  end

  def drag(x,y,event)
    next_frame
  end
end
