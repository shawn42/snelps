require 'rubygame/ftor'
module Movable 
  attr_accessor :dest

  def self.included(target)
    target.add_update_listener :update_movable 
    target.add_setup_listener :setup_movable 
  end

  def setup_movable(args)
    @base_speed = self.speed / 1000.0
  end

  def update_movable(time)
    # not sure about movement vs path stuff
    update_movement(time)
  end

  def stop_moving!()
    @dest = nil
    @path = nil
    @direction = nil
    unless @last_tile_x.nil? or (@last_tile_x == @tile_x and @last_tile_y == @tile_y)
      @grid.leave @last_tile_x, @last_tile_y 
    end
  end

  # sets the target for this unit to be tileX, tileY, direction(:sw,:s,
  # etc)
  def set_destination!(new_tile_x, new_tile_y, dir)
    # current location
    return nil if @grid.occupied?(new_tile_x, new_tile_y)
    @animation_image_set = dir
    x,y = @rect.center

    unless @last_tile_x.nil? or (@last_tile_x == @tile_x and @last_tile_y == @tile_y)
      @grid.leave @last_tile_x, @last_tile_y 
    end
    @grid.occupy(new_tile_x, new_tile_y)

    @last_tile_x = @tile_x
    @last_tile_y = @tile_y

    @tile_x = new_tile_x
    @tile_y = new_tile_y
    new_x,new_y = @map.tiles_to_coords(new_tile_x,new_tile_y)
    
    # our current target
    @dest = Ftor.new new_x, new_y

    # our current directional vector
    @direction = Ftor.new(@dest.x - x, @dest.y - y).unit
    animate
  end

  def idle?()
    @direction.nil?
  end

  def to_s()
    "UNIT:[#{@server_id}] at [#{x},#{y}] => DEST:#{@dest.inspect} DIR[#{@direction.inspect}]"
  end
end
