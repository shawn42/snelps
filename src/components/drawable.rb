module Drawable 
  attr_accessor :selected, :trace

  def self.included(target)
    target.add_setup_listener :setup_drawable
  end

  def setup_drawable(args)
    @trace = args[:trace]
    @viewport = args[:viewport]
  end

  # requires the ent to be a sprite
  def draw(destination)
    if @viewport.nil?
      puts "race condition, why is @viewport nil?"
      return nil 
    end
    x,y = @rect.center 
    w = @viewport.world_width
    h = @viewport.world_height
    x,y = @viewport.world_to_view x, y

    if @trace
      unless @dest.nil?
        startx,starty = x,y
        half_tile = @map.half_tile_size

        new_x,new_y = @viewport.world_to_view(@dest.x,@dest.y)

        destination.draw_line([startx,starty],[new_x,new_y],PURPLE)
        destination.draw_box_s([new_x-half_tile,new_y-half_tile],
          [new_x+half_tile,new_y+half_tile], LIGHT_PURPLE_HALF_ALPHA)

        startx,starty = new_x, new_y

        unless @path.nil?
          for dest in @path
            coords = dest
            new_x,new_y = @map.tiles_to_coords(coords[0],coords[1])
            new_x,new_y = @viewport.world_to_view(new_x,new_y)

#            destination.draw_line([startx,starty],[new_x,new_y],PURPLE)
            destination.draw_box_s([new_x-half_tile,new_y-half_tile],
              [new_x+half_tile,new_y+half_tile], LIGHT_PURPLE_HALF_ALPHA)
            
            startx,starty = new_x, new_y
          end
        end
      end
    end

    if @selected
      w = @selected_image.w
      h = @selected_image.h
      sx = x - (w/2)
      sy = y - (h/2)
      @selected_image.blit(destination, [sx,sy,w,h])
    end

    @image.blit(destination, 
                [x-@image.w/2,y-@image.w/2,@image.w,@image.h])
  end

end
