module Pathable

  def self.included(target)
    target.add_update_listener :update_pathable 
    target.add_setup_listener :setup_pathable 
  end

  def setup_pathable(args)
    require_components :positionable, :movable

    @grid = args[:occupancy_grid]
    @entity_manager = args[:entity_manager]
  end

  def update_pathable(time)
    # not sure about movement vs path stuff
    update_movement(time)
  end

  def path=(path)
    @path = path
  end

  def create_new_path(to_x, to_y, max=80)
    from = [@tile_x, @tile_y]
    to = [to_x,to_y]
    Pathfinder.new(z, @entity_manager, @map.w, @map.h).find(from,to,max)
  end

  # TODO clean up this code, there's duplicate code everywhere and its
  # too long of a method
  def update_movement(time)
    if @dest.nil?
      unless @path.nil? or @path.empty?
        dest = @path.shift

        if @entity_manager.has_obstacle?(dest[0], dest[1], @entity_type, [self])
          to = @path.pop
          while !to.nil? and @entity_manager.has_obstacle?(to[0], to[1], @entity_type, [self]) 
            to = @path.pop
          end

          if to.nil? or to.empty?
            stop_moving!
          else
            self.path = create_new_path to[0], to[1]
          end

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
          if @entity_manager.has_obstacle?(dest[0], dest[1], z, [self])
            # nil check path
            if @path.empty?
              stop_moving!
            else
              to = @path.pop
              while !to.nil? and @entity_manager.has_obstacle?(to[0], to[1], z, [self]) 
                to = @path.pop
              end

              if to.nil?
                stop_moving!
                dest = nil
                p "AAHHH, no where to go!?!?! taking a break"
              else
                self.path = create_new_path to[0], to[1] 
                dest = @path.shift unless @path.nil?
              end
            end
          end
          if dest.nil?
            @dest = nil
          else
            set_destination! dest[0], dest[1], dest[2]
          end
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
