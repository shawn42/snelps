
module Animated
  attr_accessor :image, :selected_image, :animation_length,
    :animation_image_set

  def self.included(target)
    target.add_setup_listener :setup_animated
  end

  def setup_animated(*arg_list)
    args = arg_list.shift
    @animated_time = 0
    @frame_num = 0

    @animation_manager = args[:animation_manager]
    @animation_manager.register(self)

    @image = @animation_manager.get_default_frame(@entity_type)

    x = args[:x]
    y = args[:y]
		@rect = Rect.new(x,y,*@image.size)
    @selected_image = 
      @animation_manager.get_selection_image(@entity_type).
      zoom([0.25,0.25], true)
  end
  
  def frame_num()
    return @frame_num
  end

  def next_frame_num()
    # use the class version to keep our instance from loading a copy of animations
    (@frame_num + 1) % self.class.default_animations[:moving][@animation_image_set].size
  end

  def next_frame(img)
    @frame_num = next_frame_num
    @image = img
  end

  def last_animated_time()
    @animated_time
  end

  def last_animated_time=(time)
    @animated_time = time
  end
  
  def stop_animating()
    @animating = false
  end

  def animate()
    @animating = true
  end

  def animating?()
    @animating
  end

  def animation_length()
    # TODO hack, ugly
    set = self.class.default_animations[:moving][animation_image_set]

    set.nil? ? 1 : set[:last]-set[:first]+1
  end

  def animation_image_set()
    @animation_image_set ||= :idle
  end

  def object_type()
    @entity_type
  end

end
