require 'pathfinder_ll'
require 'publisher'
require 'commands'
require 'entity'
require 'entity_selection'
class EntityManager
  extend Publisher
  include Commands

  attr_accessor :map, :occupancy_grids, :current_selection, :current_action, :selections, :current_abilities
  can_fire :sound_play, :network_msg_to

  constructor :viewport, :resource_manager, :sound_manager, :network_manager, :mouse_manager, :input_manager, :ability_manager
  def setup()
    @trace = false
    
    # stores the selections for later retrieval
    @selections = {}
    @current_action = ENTITY_MOVE

    @available_z_levels = []
    @z_entities = {}
    @id_entities = {}
    @occupancy_grids = {}
  end

  def find_entity_by_id(server_id)
    @id_entities[server_id]
  end

  # TODO actual target "locking"
  def handle_attack(cmd)
    fire :sound_play, :ent_attack
    attack_cmd,entity_id,tile_x,tile_y = cmd.split ':'
    # if targetable ent is at x, y
    ents = get_occupants_at(tile_x.to_i, tile_y.to_i)
    targetable_ents = ents.select{|e|e.player_id != 1}
    if targetable_ents.empty?
      # TODO set aggressive mode?
      move_entity cmd
#      ent.melee_attack :target => [tile_x,tile_y]
    else
      ent = @id_entities[entity_id.to_i]
      # TODO lock onto this unit
      p "ATTACK!!! #{ent.server_id} => #{targetable_ents.first.server_id}"
      ent.melee_attack :target => targetable_ents.first
      # attack
    end
  end

  def handle_move(cmd)
    fire :sound_play, :ent_move
    move_entity cmd
  end

  def move_entity(cmd)
    move_cmd,entity_id,dest_tile_x,dest_tile_y = cmd.split ':'

    entity_id = entity_id.to_i
    dest_tile_x = dest_tile_x.to_i
    dest_tile_y = dest_tile_y.to_i
    
    entity = @id_entities[entity_id]

    entity.path_to dest_tile_x, dest_tile_y if entity.is? :pathable
  end

  def has_obstacle?(x, y, z, ignore_objects = [])
    # for now 266 is water, only flying entities can go on them
    begin
      occ = @occupancy_grids[z].nil? ? false : @occupancy_grids[z].occupied?(x, y)
      water_check = ((@map.at(x,y) == 266) and (z == 1))
      return (occ or water_check)
    rescue Exception => ex
      p ex
    end

  end

  def handle_key_up(event)
    case event.key
    when K_T
      @trace = !@trace
      for entity in @id_entities.values
        entity.trace = @trace
      end
    when K_R
      # report (mostly for debugging)
      for entity in @id_entities.values
        puts entity
      end
    when K_M
      @current_action = ENTITY_MOVE
    when K_A
      @current_action = ENTITY_ATTACK
    when K_1
      change_group_selection event, 1
    when K_2
      change_group_selection event, 2
    when K_3
      change_group_selection event, 3
    when K_4
      change_group_selection event, 4
    when K_5
      change_group_selection event, 5
    when K_6
      change_group_selection event, 6
    when K_7
      change_group_selection event, 7
    when K_8
      change_group_selection event, 8
    when K_9
      change_group_selection event, 9
    when K_0
      change_group_selection event, 0
    end
  end

  # update the current group selection based on whether the CRTL keys are press
  # with the number.
  def change_group_selection(event, num)
    if event.mods.include? K_LCTRL or event.mods.include? K_RCTRL
      @selections[num] = @current_selection 
    else
      clear_entity_selection
      @current_selection = @selections[num]
      @current_selection.select unless @current_selection.nil?
    end
  end
  
  # select all entities within this world coord box
  def select_in(x,y,dx=0,dy=0)
    selection_change = false
    dragging = (dx > 0 or dy > 0)

    world_x, world_y = @viewport.view_to_world(x, y)
    world_dx, world_dy = @viewport.view_to_world(x+dx, y+dy)

    tile_x,tile_y = 
      @map.coords_to_tiles(world_x,world_y)
    tile_dx,tile_dy = 
      @map.coords_to_tiles(world_dx,world_dy)

    tdx = tile_dx - tile_x
    tdy = tile_dy - tile_y

    tdx = 1 if tdx == 0
    tdy = 1 if tdy == 0

    newly_current_selection = {}
    for z, grid in @occupancy_grids
      grid_ents = grid.get_occupants tile_x, tile_y, tdx, tdy
      unless grid_ents.empty?
        for entity in grid_ents
          # TODO, unhardcode the player id
          if entity.is? :selectable and entity.player_id == 1
            # still select if we are dragging, but if clicking we 
            # don't want them selected anymore
            selection_change = true
            if dragging
              if entity.is? :selectable
                newly_current_selection[entity.server_id] = entity
              end
            else
              if entity.is? :selectable
                unless entity.selected?
                  newly_current_selection[entity.server_id] = entity
                end
              end
            end
          end
        end
      end
    end

    if selection_change or dragging
      clear_entity_selection 
      @current_selection.deselect unless @current_selection.nil?
      @current_selection = EntitySelection.new newly_current_selection
    end

    @current_abilities = @ability_manager.abilities_for @current_selection
    selection_change
  end

  def clear_entity_selection()
    @current_selection.deselect unless @current_selection.nil?
    @current_selection = nil
  end

  # send cmd to perform given action on selected units (move, attack, etc)
  def do_action(x,y)
    if @current_selection
      for id, entity in @current_selection.entities
        # doesn't have to be pathable.. (stationary ranged attack?)
        if entity.is? :pathable
          # we clicked to send them an order
          world_x, world_y = @viewport.view_to_world(x, y)

          tile_x,tile_y = 
            @map.coords_to_tiles(world_x,world_y)

          cmd = "#{@current_action}:#{entity.server_id}:#{tile_x}:#{tile_y}"
          fire :network_msg_to, cmd
        end
      end
    end
  end

  def handle_mouse_click(event)
    pos = event.pos
    x = pos.first
    y = pos.last

    # if we are not selecting ents, do action
    unless select_in x, y
      do_action x, y
    end
  end

  def handle_mouse_drag(x, y, event)
    pos = event.pos
		x_array = [x, pos.first].sort
		y_array = [y, pos.last].sort
    # TODO change to use select_in
    select_in x_array.first,y_array.first, x_array.last -
                     x_array.first ,y_array.last - y_array.first
  end
  
  def create_entity(p_id, entity_type, x, y, ent_id)
    begin
      klass = Object.const_get Inflector.camelize(entity_type)
      z = klass.default_z
      unless @available_z_levels.include? z
        @available_z_levels << z
        @available_z_levels.sort!
        @occupancy_grids[z] = OccupancyGrid.new @map.width, @map.height
      end
      @z_entities[z] ||= []

      new_entity = klass.new(ent_id,
       {
        :resource_manager => @resource_manager,
        :sound_manager => @sound_manager,
        :viewport => @viewport,
        :entity_type => entity_type,
        :server_id => ent_id,
        :occupancy_grid => @occupancy_grids[z],
        :map => @map,
        :entity_manager => self,
        :x => x,
        :y => y,
        :trace => @trace
       }
      )
      # TODO should I pull this up into args params?
      new_entity.player_id = p_id

      @z_entities[z] << new_entity
      @id_entities[ent_id] = new_entity

      new_entity.animate if new_entity.is? :animated
    rescue Exception => ex
      p ex
      caller.each do |c|
        p c
      end
    end
    new_entity
  end

  def update(time)
    for entity in @id_entities.values
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
      x = tl_tile[0]-1
      y = tl_tile[1]-1
      w = br_tile[0]-x+1
      h = br_tile[1]-y+1
      @occupancy_grids[az].get_occupants(x,y,w,h).each do |ze|
        ze.draw destination
      end
    end
  end

  def get_occupants_at(x,y,w=1,h=1,player=nil)
    occs = []
    for z,grid in @occupancy_grids
      occs << grid.get_occupants(x, y, w, h, player)
      occs.flatten!
    end
    occs
  end

  # called to generate ENTITY_CREATE cmd
  def create_entity_cmd(p_id,ent_type,tile_x,tile_y)
    [ENTITY_CREATE,p_id,ent_type,tile_x,tile_y].join ":"
  end

  # called when an ENTITY_CREATE cmd comes in
  # ie ENTITY_CREATE:player_id:ent_type:x:y:ent_id
  def handle_create(cmd)
    create_cmd,p_id,ent_type,tile_x,tile_y,ent_id = cmd.split ':'
    p_id = p_id.nil? ? nil : p_id.to_i
    create_entity p_id, ent_type.to_sym, tile_x.to_i, tile_y.to_i, ent_id.to_i
  end
end
