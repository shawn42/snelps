
module Animated
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

end
