module UnitComponent

  attr_accessor :unit_type, :selected, :dest, :trace

  def setup_unit_component(args = {})
    @unit_type = args[:unit_type]
    @server_id = args[:server_id]
    
    @animation_length = 8
    @animation_manager = args[:animation_manager]
    @animation_manager.register(self)


    @sound_manager = args[:sound_manager]
    @viewport = args[:viewport]
    @map = args[:map]
    @grid = args[:occupancy_grid]
    @entity_manager = args[:entity_manager]
    x = args[:x]
    y = args[:y]
    @trace = args[:trace]

    @tile_x, @tile_y = @map.coords_to_tiles x, y
    @grid.occupy @tile_x, @tile_y

    @image = @animation_manager.get_default_frame(@unit_type)
		@rect = Rect.new(x,y,*@image.size)

    @selected_image = 
      @animation_manager.get_selection_image(@unit_type).
      zoom([0.25,0.25], true)
  end

  def self.included(target)
    target.add_update_listener :update_unit_component
    target.add_setup_listener :setup_unit_component
  end

  def update_unit_component(time)
    update_movement(time)
  end

  def path=(path)
    #ignore the starting square
#    path.shift unless path.nil?
    @dest = nil
    @path = path
  end

  def update_movement(time)
    if @dest.nil?
      unless @path.nil? or @path.empty?
        dest = @path.shift

        if @entity_manager.has_obstacle?(dest[0], dest[1], @unit_type, [self])
          from = @map.coords_to_tiles(x,y)

          # what if we are on the last step of the path?
          to = @path.last

          if to.nil? or to.empty?
            stop_moving!
          else
            path = Pathfinder.new(@unit_type, @entity_manager, @map.w, @map.h).find(from,to,80)
          end


          @path = path
          dest = @path.shift unless @path.nil? or @path.empty?
        end
        set_destination! dest[0], dest[1], dest[2] unless dest.nil?
      end
    else
      # TODO XXX this is kind of a hack
      @direction = Vec2.new @dest.x - x, @dest.y - y
      @direction.normalize!
      if (x - @dest.x).abs < 6 and (y - @dest.y).abs < 6
        if @path.nil? or @path.empty?
          stop_moving!
        else
          dest = @path.shift
          if @entity_manager.has_obstacle?(dest[0], dest[1], @unit_type, [self])
            # nil check path
            if @path.empty?
              stop_moving!
            else
              from = @map.coords_to_tiles(x,y)
              # what if we are on the last step of the path?
              to = @path.last
              # TODO XXX
              # NOT SURE WHAT TO DO ABOUT THE PATH HERE?
              # maybe walk the path backwards and get as close as
              # possible?
              if @entity_manager.has_obstacle?(to[0], to[1], @unit_type, [self])
                stop_moving!
                dest = nil
                p "AAHHH, no where to go!?!?!"
              else
                path = Pathfinder.new(@unit_type, @entity_manager, @map.w, @map.h).find(from,to,80)
  #              path.shift
                @path = path
                dest = @path.shift unless @path.nil?
              end
            end
          end
          set_destination! dest[0], dest[1], dest[2] unless dest.nil?
        end
      else
        # move toward dest
        base = @base_speed * time.milliseconds
        move = @direction * base
        @rect.centerx = x + move.x
        @rect.centery = y + move.y
      end
    end
    if @dest.nil?
      stop_animating 
    else
      animate
    end
  end

  # sets the target for this unit to be tileX, tileY, direction(:sw,:s,
  # etc)
  def set_destination!(new_tile_x, new_tile_y, dir)
    # current location
    return nil if @grid.occupied?(new_tile_x, new_tile_y)
    @animation_image_set = dir
    x,y = @rect.center

    @grid.leave @last_tile_x, @last_tile_y unless @last_tile_x.nil?
    @grid.occupy(new_tile_x, new_tile_y)

    @last_tile_x = @tile_x
    @last_tile_y = @tile_y

    @tile_x = new_tile_x
    @tile_y = new_tile_y
    new_x,new_y = @map.tiles_to_coords(new_tile_x,new_tile_y)
    
    # our current target
    @dest = Vec2.new new_x, new_y

    # our current directional vector
    @direction = Vec2.new @dest.x - x, @dest.y - y

    @direction.normalize!
  end

  def stop_moving!()
    @dest = nil
    @path = nil
    @direction = nil
    @grid.leave @last_tile_x, @last_tile_y unless @last_tile_x.nil?
  end

  def draw(destination)
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

  def x();@rect.centerx;end
  def y();@rect.centery;end

  def in_tile?(pos)
    world_x, world_y = @map.tiles_to_coords(pos[0],pos[1])
    tile_size = @map.tile_size
    world_rect = Rect.new world_x, world_y, tile_size, tile_size
    @rect.collide_rect? world_rect
  end

  def in?(rect)
    world_x, world_y = @viewport.view_to_world(rect.x, rect.y)
    world_rect = Rect.new world_x, world_y, rect.w, rect.h
    @rect.collide_rect? world_rect
  end

  def hit_by?(x, y)
    world_x, world_y = @viewport.view_to_world(x, y)
    @rect.collide_point? world_x, world_y
  end

  def idle?()
    @direction.nil?
  end

  def animation_image_set()
    @animation_image_set ||= :se
  end

  def object_type()
    @unit_type
  end

  def to_s()
    "UNIT:[#{@server_id}] at [#{x},#{y}] => DEST:#{@dest.inspect} DIR[#{@direction.inspect}]"
  end
end
