module Pathable

  def self.included(target)
    target.add_update_listener :update_pathable 
    target.add_setup_listener :setup_pathable 
  end

  def setup_pathable(args)
    # requires positionable to be included prior
    @grid = args[:occupancy_grid]
    @entity_manager = args[:entity_manager]
    @grid.occupy @tile_x, @tile_y
  end

  def update_pathable(time)
  end

  def path=(path)
    stop_moving!
    @path = path
  end

  # TODO clean up this code, there's duplicate code everywhere and its
  # too long of a method
  def update_movement(time)
    if @dest.nil?
      unless @path.nil? or @path.empty?
        dest = @path.shift

        if @entity_manager.has_obstacle?(dest[0], dest[1], @unit_type, [self])
          from = @map.coords_to_tiles(x,y)

          to = @path.pop
          while !to.nil? and @entity_manager.has_obstacle?(to[0], to[1], @unit_type, [self]) 
            to = @path.pop
          end

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
      # should I draw line from previous point to now and see if target
      # is on the line?
      @direction = Ftor.new(@dest.x - x, @dest.y - y).unit
      if (x - @dest.x).abs < 5 and (y - @dest.y).abs < 5
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

              to = @path.pop
              while !to.nil? and @entity_manager.has_obstacle?(to[0], to[1], @unit_type, [self]) 
                to = @path.pop
              end

              if to.nil?
                stop_moving!
                dest = nil
                p "AAHHH, no where to go!?!?! taking a break"
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
        base = @base_speed * time
        move = @direction * base
        @rect.centerx = x + move.x
        @rect.centery = y + move.y
      end
    end
    if @dest.nil?
      stop_animating 
    end
  end
  

end
