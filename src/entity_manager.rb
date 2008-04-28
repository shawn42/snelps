require 'pathfinder_ll'
require 'commands'
require 'entity'
class EntityManager
  include Commands

  attr_accessor :map, :occupancy_grids, :entities

  constructor :viewport, :animation_manager, :sound_manager, :network_manager, :mouse_manager, :input_manager
  def setup()
    @trace = false
    @entities = []
  end

  def occupancy_grid(unit_type)
    case unit_type
    when :unit_bird
      @occupancy_grids[:flying]
    else
      @occupancy_grids[:ground] 
    end
  end

  def handle_entity_move(cmd)
    move_cmd,entity_id,dest_tile_x,dest_tile_y = cmd.split ':'
    entity_id = entity_id.to_i
    dest_tile_x = dest_tile_x.to_i
    dest_tile_y = dest_tile_y.to_i
    
    # TODO, put entities in a hash by server_id
    for entity in @entities
      if entity.server_id == entity_id
        tile_x,tile_y = 
          @map.coords_to_tiles(entity.x,entity.y)
        
        from = [tile_x,tile_y]
        to = [dest_tile_x,dest_tile_y]
        unless has_obstacle?(dest_tile_x, dest_tile_y, entity.unit_type)
          max = 80
          path = Pathfinder.new(entity.unit_type, self, @map.w, @map.h).find(from,to,max)
          if path.nil?
            entity.stop_animating
          else
            entity.path = path 
          end
        end
      end
    end
  end

  # TODO, I'm pretty sure there is a GIANT race condition here
  def has_obstacle?(x, y, unit_type, ignore_objects = [])
    begin
      # for now 266 is water, only flying entities can go on them
      case unit_type
      when :unit_bird
        # only obs is another bird
        return occupancy_grid(unit_type).occupied?(x, y)
      else
        # ground entities
        if @map.at(x, y) == 266
          return true
        else
          return occupancy_grid(unit_type).occupied?(x, y)
        end
      end
    rescue Exception => ex
      p ex
      caller.each do |frame|
        p frame
      end
    end
    false
  end

  def handle_key_up(event)
    case event.key
    when :t
      @trace = !@trace
      for entity in @entities
        entity.trace = @trace
      end
    when :r
      # report (mostly for debugging)
      for entity in @entities
        puts entity
      end
    end
  end
  
  def handle_mouse_click(event)
    pos = event.pos
    x = pos.first
    y = pos.last
    selected_entity = nil

    for entity in @entities
      if entity.hit_by? pos[0], pos[1]
        if entity.selected
          entity.selected = false
        else
          selected_entity = entity
          entity.selected = true
        end
        break
      end
    end

    if selected_entity.nil?
      for entity in @entities
        if entity.selected
          # we clicked to send them an order
          world_x, world_y = @viewport.view_to_world(x, y)

          tile_x,tile_y = 
            @map.coords_to_tiles(world_x,world_y)

          cmd = "#{ENTITY_MOVE}:#{entity.server_id}:#{tile_x}:#{tile_y}"
          @network_manager[:to_server].push cmd
        end
      end
    else
      for entity in @entities
        unless entity == selected_entity
          entity.selected = false
        end
      end
    end
  end

  def handle_mouse_drag(x, y, event)
    pos = event.pos
		x_array = [x, pos.first].sort
		y_array = [y, pos.last].sort
    rect = Rect.new(x_array.first,y_array.first, x_array.last -
                     x_array.first ,y_array.last - y_array.first)
    for entity in @entities
      entity.selected = false
      if entity.in? rect
        entity.selected = true
      end
    end
  end
  
  def create_entity(unit_type, x, y)
    # TODO, send CREATE_entity CMD?
    @@entity_count ||= 0
    @@entity_count += 1
    new_entity_id = @@entity_count #@game_server.create_entity(unit_type, x, y)

    begin
    klass = Object.const_get Inflector.camelize(unit_type)
    new_entity = klass.new(new_entity_id,
     {
      :animation_manager => @animation_manager,
      :sound_manager => @sound_manager,
      :viewport => @viewport,
      :unit_type => unit_type,
      :server_id => new_entity_id,
      :map => @map,
      :occupancy_grid => occupancy_grid(unit_type),
      :entity_manager => self,
      :x => x,
      :y => y,
      :trace => @trace
     }
      )
    @entities << new_entity
    rescue Exception => ex
      p ex
      caller.each do |c|
        p c
      end
    end
    new_entity
  end

  def update(time)
    for entity in @entities
      entity.update(time)
    end
  end
  
  def draw(destination)
    if @trace
      half_tile = @map.half_tile_size
      @map.width.times do |i|
        @map.height.times do |j|
          if occupancy_grid(:unit_bird).occupied?(i,j)
            occ_x, occ_y = @map.tiles_to_coords(i,j)
            occ_x, occ_y = @viewport.world_to_view(occ_x,occ_y)

            destination.draw_box_s([occ_x-half_tile,occ_y-half_tile],
              [occ_x+half_tile,occ_y+half_tile], RED_HALF_ALPHA)
          end
          if occupancy_grid(:unit_worker).occupied?(i,j)
            occ_x, occ_y = @map.tiles_to_coords(i,j)
            occ_x, occ_y = @viewport.world_to_view(occ_x,occ_y)

            destination.draw_box_s([occ_x-half_tile,occ_y-half_tile],
              [occ_x+half_tile,occ_y+half_tile], RED_HALF_ALPHA)
          end
        end
      end
    end
    @entities.each do |u|
      u.draw destination
    end
  end
end
