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

    # can I pull this out into a selectable componenet?
    if is? :selectable and selected?
      w = @selected_image.w
      h = @selected_image.h
      sx = vx - (w/2)
      sy = vy - (h/2)
      @selected_image.blit(destination, [sx,sy,w,h])
    end

#    puts "#{@rect.centerx}#{@rect.centery}:#{x}#{y}:#{vx}#{vy}"
    @image.blit(destination, 
                [vx-@image.w/2,vy-@image.w/2])

    if is? :selectable and selected?
      hb_x = vx - 10
      hb_y = vy - 20

      destination.draw_box_s([hb_x,hb_y],
        [hb_x+HB_WIDTH,hb_y+HB_HEIGHT], RED)
      hb_fill = health/self.class.default_health * HB_WIDTH
      destination.draw_box_s([hb_x,hb_y],
        [hb_x+hb_fill,hb_y+HB_HEIGHT], GREEN)
    end
  end

end
