require 'inflector'
class AnimationManager
  # TODO how to do this for all machine speeds?
  FRAME_UPDATE_TIME = 60

  constructor :resource_manager
  def setup()
    @animated_objects = []
    @images = {}
    @entity_defs = {}
  end

  def register_class(ent_type)
    animated_class = Object.const_get(Inflector.camelize(ent_type))

    # TODO, why do all these names live in each instance?
    # TODO change this stuff to be player specific?
    # maybe add another layer
    # :red => {:unit_bird => ...}
    # :blue => {:unit_bird => ...}
    @images[ent_type] ||= {}
    for action, images in animated_class.default_animations
      if images.has_key? :prefix
        # single direction
        @images[ent_type][action] = []
        f = images[:first]
        l = images[:last]
        range = Range.new f, l
        range.each do |i|
          file_name = "#{images[:prefix]}#{i}#{images[:suffix]}"
          img = @resource_manager.load_image(file_name,ent_type)
          @images[ent_type][action] << img
        end
      else
        # many directions
        for k, v in images
          # TODO actually use the action...
          @images[ent_type][k] = []
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

            @images[ent_type][k] << img

          end
        end 
      end
    end
  end

  def register(animated_object)
    @animated_objects << animated_object
  end

  # returns the image
  def get_default_frame(entity_type)
    @images[entity_type][:idle].first
  end

  def get_selection_image(entity_type)
    @images[entity_type][:selected].first
  end

  def update(time)
    for obj in @animated_objects
      if obj.animating?
        if obj.last_animated_time > FRAME_UPDATE_TIME
          obj.next_frame(@images[obj.object_type][obj.animation_image_set][obj.next_frame_num]) 
          obj.last_animated_time = 0
        else
          obj.last_animated_time += time
        end
      end
    end
  end
    
end

