class AnimationManager
  # TODO how to do this for all machine speeds?
  FRAME_UPDATE_TIME = 60
  def initialize()
    @animated_objects = []
  end

  def register(animated_object)
    @animated_objects << [0,animated_objects]
  end

  def update(time)
    @animated_objects.each do |animation_array|
      last_animated,obj = animation_array
      if last_animated > FRAME_UPDATE_TIME
        @frame = (@frame - 1) % @@images[obj.unit_type][obj.image_set].size
        last_animated = 0
      else
        last_animated += time
      end
    end
  end

end
