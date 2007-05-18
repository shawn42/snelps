class AnimationManager
  # TODO how to do this for all machine speeds?
  FRAME_UPDATE_TIME = 60
  def initialize(resource_manager)
    @resource_manager = resource_manager
    @animated_objects = []
  end

  def register(animated_object)
    @animated_objects << [0,animated_object]
  end

  # returns the image
  def get_default_frame(unit_type)
    # TODO does this matter?
    @resource_manager.load_image('unit0r.png')
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
