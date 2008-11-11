module Drawable 
  attr_accessor :trace

  HB_HEIGHT = 2
  HB_WIDTH = 20

  def self.included(target)
    target.add_setup_listener :setup_drawable
  end

  def setup_drawable(args)
    @trace = args[:trace]
    @viewport = args[:viewport]
    @map = args[:map]
  end

  # requires the ent to be a sprite
  def draw(destination)
    if @viewport.nil?
      puts "race condition, why is @viewport nil?"
      return nil 
    end
    w = @viewport.world_width
    h = @viewport.world_height
    vx,vy = @viewport.world_to_view self.x, self.y
    half_tile = @map.half_tile_size

    if @trace
      unless @dest.nil?
        startx,starty = vx,vy

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

    draw_coords = nil
    selection_coords = nil
    selection_radius = nil
    ht = @map.half_tile_size
    ts = @map.tile_size

    if respond_to? :size and self.size
      pixel_width = (self.size[0] * ts)
      pixel_height = (self.size[1] * ts)
      @w_offset ||= (@image.size[0] - pixel_width)/2 + ht
      @h_offset ||= (@image.size[1] - pixel_height)/2 + ht
      draw_x = vx-@w_offset
      draw_y = vy-@h_offset
      draw_coords = [draw_x,draw_y]
      half_width = pixel_width/2
      selection_coords = [draw_x+half_width, draw_y+pixel_height/2]
      selection_radius = half_width
    else
      draw_coords = [vx-@image.w/2,vy-@image.w/2]
      selection_coords = [draw_coords[0]+ht, draw_coords[1]+ht]
      selection_radius = ht
    end

    # can I pull this out into a selectable componenet?
    if is? :selectable and selected?
      destination.draw_circle_a(selection_coords, selection_radius, GREEN)
    end


    @image.blit(destination, draw_coords)

    if is? :selectable and selected?
      hb_x = selection_coords[0]-HB_WIDTH/2
      hb_y = vy - 20

      destination.draw_box_s([hb_x,hb_y],
        [hb_x+HB_WIDTH,hb_y+HB_HEIGHT], RED)
      hb_fill = health/self.class.default_health * HB_WIDTH
      destination.draw_box_s([hb_x,hb_y],
        [hb_x+hb_fill,hb_y+HB_HEIGHT], GREEN)
    end
  end

end
