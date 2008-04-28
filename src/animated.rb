
module Animated
  attr_accessor :image, :selected_image, :animation_length,
    :animation_image_set

  def self.included(target)
    target.add_update_listener :update_animated
    target.add_setup_listener :setup_animated
  end

  def update_animated(time)
  end

  def setup_animated(*arg_list)
    args = arg_list.shift
    @animation_length = 8
    @animation_manager = args[:animation_manager]
    @animation_manager.register(self)

    @image = @animation_manager.get_default_frame(@unit_type)
    x = args[:x]
    y = args[:y]
		@rect = Rect.new(x,y,*@image.size)
    @selected_image = 
      @animation_manager.get_selection_image(@unit_type).
      zoom([0.25,0.25], true)
  end
  
  def frame_num()
    return @frame_num
  end
  def frame_num=(frame_num)
    @frame_num = frame_num
  end

  def next_frame_num()
    (@frame_num + 1) % @frame_count
  end

  def next_frame(img)
    @frame_num = next_frame_num
    @image = img
  end

  def frame_count=(count)
    @frame_count = count
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
    @animation_length.nil? ? 1 : @animation_length
  end

  def animation_image_set()
    @animation_image_set ||= :default
  end

  def object_type()
    @unit_type
  end

#  def animation_image_set()
#    @animation_image_set ||= :se
#  end

end
