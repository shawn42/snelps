require 'image_list'
class AnimationManager
  # TODO how to do this for all machine speeds?
  FRAME_UPDATE_TIME = 60

  constructor :resource_manager
  def setup()
    STDOUT.puts "loading images..."
    load_images
    STDOUT.write "done.\n"
    @animated_objects = []
  end

  def register(animated_object)
    animated_object.frame_num = 0
    animated_object.last_animated_time = 0
    animated_object.frame_count = animated_object.animation_length
    @animated_objects << animated_object
  end

  # returns the image
  def get_default_frame(entity_type)
    @images[entity_type][:default].first
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

  def load_images
    @images = {}
    for type, dir in IMAGE_NAMES
      @images[type] = {}
      for k, v in dir
        @images[type][k] = []
        for file_name in v
          img = @resource_manager.load_image(file_name,type)
          # TODO change this stuff to be player specific?
          # maybe add another layer
          # :red => {:unit_bird => ...}
          # :blue => {:unit_bird => ...}
          if type == :unit_bird and k != :default and k != :selected
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
          @images[type][k] << img
        end
      end
    end
    @images
  end
    
end

