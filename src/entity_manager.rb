require 'pathfinder_ll'
require 'publisher'
require 'commands'
require 'entity'
class EntityManager
  extend Publisher
  include Commands

  attr_accessor :map, :occupancy_grids, :entities
  can_fire :sound_play, :network_msg_to

  constructor :viewport, :resource_manager, :sound_manager, :network_manager, :mouse_manager, :input_manager
  def setup()
    @trace = false
    @entities = []
    @available_z_levels = []
    @z_entities = {}
    @id_entities = {}
    @occupancy_grids = {}
  end

  def handle_entity_move(cmd)
    move_cmd,entity_id,dest_tile_x,dest_tile_y = cmd.split ':'
    entity_id = entity_id.to_i
    dest_tile_x = dest_tile_x.to_i
    dest_tile_y = dest_tile_y.to_i
    
    entity = @id_entities[entity_id]
#    tile_x,tile_y = 
#      @map.coords_to_tiles(entity.x,entity.y)
    
    from = [entity.tile_x,entity.tile_y]
    to = [dest_tile_x,dest_tile_y]
    unless has_obstacle?(dest_tile_x, dest_tile_y, entity.z)
      max = 80
      path = Pathfinder.new(entity.z, self, @map.w, @map.h).find(from,to,max)
      if path.nil?
        entity.stop_animating
      else
        entity.path = path 
      end
    end
  end

  def has_obstacle?(x, y, z, ignore_objects = [])
    # for now 266 is water, only flying entities can go on them
    begin
      occ = @occupancy_grids[z].nil? ? false : @occupancy_grids[z].occupied?(x, y)
      water_check = ((@map.at(x,y) == 266) and (z == 1))
#      p "occupied:#{occ} water#{water_check}"
      return (occ or water_check)
    rescue Exception => ex
      p ex
    end

  end

  def handle_key_up(event)
    case event.key
    when K_T
      @trace = !@trace
      for entity in @entities
        entity.trace = @trace
      end
    when K_R
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
        if entity.selected and entity.respond_to? :path=
          # we clicked to send them an order
          world_x, world_y = @viewport.view_to_world(x, y)

          tile_x,tile_y = 
            @map.coords_to_tiles(world_x,world_y)


          # TODO properly pass around sound events, these should come from the audible component
          fire :sound_play, :unit_move
          cmd = "#{ENTITY_MOVE}:#{entity.server_id}:#{tile_x}:#{tile_y}"
          fire :network_msg_to, cmd
#          @network_manager[:to_server].push cmd
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
  
  def create_entity(entity_type, x, y)
    # TODO, send CREATE_ENTITY CMD?
    @@entity_count ||= 0
    @@entity_count += 1
    new_entity_id = @@entity_count #@game_server.create_entity(entity_type, x, y)
    
    begin
      klass = Object.const_get Inflector.camelize(entity_type)
      z = klass.default_z
      unless @available_z_levels.include? z
        @available_z_levels << z
        @available_z_levels.sort!
        @occupancy_grids[z] = OccupancyGrid.new @map.width, @map.height
      end
      @z_entities[z] ||= []

      new_entity = klass.new(new_entity_id,
       {
        :resource_manager => @resource_manager,
        :sound_manager => @sound_manager,
        :viewport => @viewport,
        :entity_type => entity_type,
        :server_id => new_entity_id,
        :occupancy_grid => @occupancy_grids[z],
        :map => @map,
        :entity_manager => self,
        :x => x,
        :y => y,
        :trace => @trace
       }
      )

      # TODO should this be the ONLY storage of ents?
      @z_entities[z] << new_entity

      @id_entities[new_entity_id] = new_entity
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
          for z, grid in @occupancy_grids
            if grid.occupied?(i,j)
              occ_x, occ_y = @map.tiles_to_coords(i,j)
              occ_x, occ_y = @viewport.world_to_view(occ_x,occ_y)

              destination.draw_box_s([occ_x-half_tile,occ_y-half_tile],
                [occ_x+half_tile,occ_y+half_tile], RED_HALF_ALPHA)
            end
          end
        end
      end
    end

    @available_z_levels.each do |az|

      view_x = @viewport.x_offset
      view_y = @viewport.y_offset
      view_w = @viewport.width
      view_h = @viewport.height
      tl_tile = @map.coords_to_tiles view_x, view_y
      br_tile = @map.coords_to_tiles view_x+view_w, view_y+view_h
      x = tl_tile[0]
      y = tl_tile[1]
      w = br_tile[0]-x
      h = br_tile[1]-y
      @occupancy_grids[az].get_occupants(x,y,w,h).each do |ze|
#      @z_entities[az].each do |ze|
        ze.draw destination
      end
    end
  end
end
