module Animated
  # TODO how to do this for all machine speeds?
  FRAME_UPDATE_TIME = 60

  attr_accessor :image, :selected_image, :animation_image_set

  def self.included(target)
    target.add_setup_listener :setup_animated
    target.add_update_listener :update_animated
    target.metaclass.send :define_method, :animated_class_setup do |resource_manager, ent_type|
    @resource_manager = resource_manager
    @images = {}
    for action, images in default_animations
      if images.has_key? :prefix
        # single direction
        @images[action] = []
        f = images[:first]
        l = images[:last]
        range = Range.new f, l
        range.each do |i|
          file_name = "#{images[:prefix]}#{i}#{images[:suffix]}"
          img = @resource_manager.load_image(file_name,ent_type)
          @images[action] << img
        end
      else
        # many directions
        for k, v in images
          # TODO actually use the action...
          @images[k] = []
          f = v[:first]
          l = v[:last]
          range = Range.new f, l
          range.each do |i|
            file_name = "#{v[:prefix]}#{i}#{v[:suffix]}"
            img = @resource_manager.load_image(file_name,ent_type)

            # red tint please...
            if ent_type == :unit_bird
              img.w.times do |c|
                img.h.times do |r|
                  oc = img.get_at(r,c)
                  unless oc[3] == 1
                    new_color = [oc[0]*1.69,oc[1]*0.09,oc[2]*0.09, oc[3]]
                    img.set_at [r,c], new_color
                  end
                end
              end
            end

            @images[k] << img

          end
        end 
      end
    end

    end
  end

  def get_default_frame(entity_type)
    self.class.instance_variable_get("@images")[:idle].first
  end

  def get_selection_image(entity_type)
    self.class.instance_variable_get("@images")[:selected].first
  end

  def update_animated(time)
    if animating?
      if @animated_time > FRAME_UPDATE_TIME
        next_frame
        @animated_time = 0
      else
        @animated_time += time
      end
    end
  end

  def setup_animated(*arg_list)
    args = arg_list.shift

    @animated_time = 0
    @frame_num = 0

    @resource_manager = args[:resource_manager]

    @image = get_default_frame(@entity_type)

    unless self.class.default_animations[:selected].nil?
      @selected_image = get_selection_image(@entity_type).
        zoom([0.25,0.25], true)
    end
  end

  def next_frame()
    # use the class version to keep our instance from loading a copy of animations
    # TODO cache this size, only update when animation_image_set changes?
    size = animation_length
    @frame_num = (@frame_num + 1) % size
    @image = self.class.instance_variable_get("@images")[animation_image_set][@frame_num]
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
    return @animation_length unless @animation_length.nil?

    # TODO hack, ugly
    set = nil
    moving_set = self.class.default_animations[:moving]
    if !moving_set.nil? and moving_set.include? animation_image_set
      set = moving_set[animation_image_set] 
    else
      set = self.class.default_animations[:idle]
    end

    @animation_length = set.nil? ? 1 : set[:last]-set[:first]+1
  end

  def animation_image_set=(set)
    unless set == @animation_image_set
      @animation_length = nil
      @animation_image_set = set
    end
  end

  def animation_image_set()
    @animation_image_set ||= :idle
  end

  def object_type()
    @entity_type
  end

end
