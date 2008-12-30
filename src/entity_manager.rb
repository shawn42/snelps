require 'pathfinder_ll'
require 'publisher'
require 'commands'
require 'entity'
require 'entity_selection'
require 'occupancy_grid'

class EntityManager
  extend Publisher
  include Commands

  attr_accessor :map, :occupancy_grids, :current_selection, 
    :selections, :current_abilities, :base_entities, :players,
    :viewable_rows, :viewable_cols, 
    :available_z_levels, :viewable_entities_dirty, 
    :viewable_entities, :current_abilities, :current_action

  can_fire :sound_play, :network_msg_to, :occupancy_grid_created, :occupancy_change, :selection_change

  constructor :viewport, :resource_manager, :sound_manager,
    :input_manager, :ability_manager 
  
  def setup()
    @trace = false
    
    # stores the selections for later retrieval
    @selections = {}

    # used to see if we need to check the occupancy_grids on draw
    @viewable_entities_dirty = true

    # :z => [visible ents]
    @viewable_entities = {}

    # map of :player_id => {:z => [ents]}
    @players_entities = {}

    @available_z_levels = []
    @z_entities = {}
    @id_entities = {}
    @base_entities = {}
    @occupancy_grids = {}

    @ability_manager.unsubscribe :create_ent, self
    @ability_manager.unsubscribe :sound_play, self

    @ability_manager.when :sound_play do |sound|
      fire :sound_play, sound
    end
    @ability_manager.when :create_ent do |p_id,ab_sym,x,y,group|
      ent = create_entity p_id,ab_sym,x,y
      @ability_manager.execute_group_ability ent, group
    end

    @current_abilities = []

    @ent_id_incrementer = 0
  end

  def find_entity_by_id(server_id)
    @id_entities[server_id]
  end

  # handle all incoming network events dealing with entities
  def handle(event)
    pieces = event.split(':')
    cmd = pieces[0]

    # special case for creation
    if cmd == ENTITY_CREATE
      create_cmd,p_id,ent_type,tile_x,tile_y = *pieces
      p_id = p_id.nil? ? nil : p_id.to_i

      create_entity p_id, ent_type.to_sym, tile_x.to_i, tile_y.to_i
    else
      # all other commands are an action for a selection towards a
      # target
      ents = pieces[1].split(',').collect{|e_id|@id_entities[e_id.to_i]}
      target = nil
      if pieces.size == 4
        # we have a location
        target = [pieces[2],pieces[3]]
      else
        # we have an id
        target = @id_entities[pieces[2].to_i]
      end
      
      action_name = cmd.slice(cmd.index("_")+1..-1)
      @ability_manager.execute_ability action_name, ents, target

    end
  end

  def has_obstacle?(x, y, z, ignore_objects = [])
    # for now 266 is water, only flying entities can go on them
    begin
      occs = @occupancy_grids[z].nil? ? [] : @occupancy_grids[z].get_occupants(x, y)

      for ent in occs
        unless ignore_objects.include? ent
          occ = true
          break
        end
      end
      # TODO PERF cache this range somewhere
      water = @map.tile_config[:water]
      @water_range ||= (water[:first]..water[:last])
      water_check = (@water_range.include?(@map.at(x,y)) and (z == 1))
      return (occ or water_check)
    rescue Exception => ex
      p ex
    end

  end

  def handle_key_up(event)
    case event.data[:key]
    when K_D
      @profiling = !@profiling
      if @profiling
        require "ruby-prof"
#        RubyProf.measure_mode = RubyProf::CPU_TIME
        RubyProf.measure_mode = RubyProf::PROCESS_TIME
#        RubyProf.measure_mode = RubyProf::WALL_TIME

        RubyProf.start 
      else
        result = RubyProf.stop
        html = true
        if(html)
          printer = RubyProf::GraphHtmlPrinter.new(result)
          file = File.open "prof/profiling-#{Time.now}.html", 'w+'
          printer.print(file, 0)
          file.close
        else
#          printer = RubyProf::FlatPrinter.new(result)
          file = File.open "prof/profiling-#{Time.now}.txt", 'w+'
          printer.print(file, 0)
          file.close
        end
      end
    when K_N
      # TODO create random wandering ent
      begin
        10.times do
          w = rand(@map.width)
          h = rand(@map.height)
          @map.script.create_entity nil, :animal, w, h
        end
        puts @id_entities.size
      rescue Exception => ex
        puts "K_N [#{ex}]"
        puts ex.backtrace
      end
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
    if event.data[:mods].include? K_LCTRL or event.data[:mods].include? K_RCTRL
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
                newly_current_selection[entity.server_id] = entity
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
    fire :selection_change if selection_change
    selection_change
  end

  def clear_entity_selection()
    @current_selection.deselect unless @current_selection.nil?
    @current_selection = nil
  end

  # send cmd to perform given action on selected units (move, attack, etc)
  def do_action(x,y)
    if @current_selection

      world_x, world_y = @viewport.view_to_world(x, y)

      tile_x,tile_y = 
        @map.coords_to_tiles(world_x,world_y)

      target = [tile_x,tile_y]

      targets = get_occupants_at(tile_x, tile_y)
      if targets.size > 0
        target = targets.first
      end

#        act = entity.actions(:target=>target).first
      # XXX hack for testing out sledgehammer stuff
      act = @current_action

#      act = @current_abilities.last unless act

      cmds = @ability_manager.command_for @current_selection, act, target

      cmds.each do |c|
        fire :network_msg_to, c
      end
    end
  end

  def handle_mouse_click(event)
    x = event.data[:x]
    y = event.data[:y]

    # if we are not selecting ents, do action
    unless select_in x, y
      do_action x, y
    end
  end

  def handle_mouse_drag(event)
    x = event.data[:start_x]
    y = event.data[:start_y]
    new_x = event.data[:x]
    new_y = event.data[:y]
		x_array = [x, new_x].sort
		y_array = [y, new_y].sort

    select_in x_array.first,y_array.first, x_array.last -
                     x_array.first ,y_array.last - y_array.first
  end
  
  def enable_entity(ent)
#    p "entity[#{ent.server_id}] enabled"

    p_id = ent.player_id
    z = ent.z
    @players_entities[p_id] ||= {}
    @players_entities[p_id][z] ||= []
    @players_entities[p_id][z] << ent
    @z_entities[z] << ent
    @id_entities[ent.server_id] = ent

    # TODO, un hardcode the player id
    @base_entities[ent.server_id] = ent if ent.is?(:collector) and ent.player_id == 1

    # assumes a knowlege that the ent is :positionable
    # should register for enabled callback?
    ent.position_at ent.tile_x, ent.tile_y
  end

  def disable_entity(ent)
#    p "entity[#{ent.server_id}] disabled"
    @viewable_entities[ent.z].delete ent
    @players_entities[ent.player_id][ent.z].delete ent

    @z_entities[ent.z].delete ent
    @id_entities.delete ent.server_id
    @base_entities.delete ent.server_id

    # assumes a knowlege that the ent is :positionable
    # should register for disabled callback?
    ent.remove_from ent.tile_x, ent.tile_y
  end

  def destroy_entity(ent)
#    p "entity[#{ent.server_id}] died"

    @viewable_entities[ent.z].delete ent
    @players_entities[ent.player_id][ent.z].delete ent

    @z_entities[ent.z].delete ent
    @id_entities.delete ent.server_id
    @base_entities.delete ent.server_id

    # assumes a knowlege that the ent is :positionable
    # should register for destroyed callback
    ent.remove_from ent.tile_x, ent.tile_y

    ent.unsubscribe :destroyed, self
  end

  def manage_entity(new_entity)
    enable_entity new_entity

    new_entity.when :destroyed do |ent|
      destroy_entity new_entity
    end
    new_entity.when :disabled do |ent|
      disable_entity new_entity
    end
    new_entity.when :enabled do |ent|
      enable_entity new_entity
    end
  end

  def create_entity(p_id, entity_type, tile_x, tile_y)
#    puts "#{p_id} #{entity_type} #{tile_x},#{tile_y}"
#    puts "#{occupancy_grids.size}"
    x, y = @map.tiles_to_coords(tile_x.to_i,tile_y.to_i)
    ent_id = @ent_id_incrementer += 1
    klass = Object.const_get Inflector.camelize(entity_type)
    z = klass.default_z
    unless @available_z_levels.include? z
      @available_z_levels << z
      @available_z_levels.sort!
      grid = OccupancyGrid.new @map.width, @map.height
      fire :occupancy_grid_created, grid, z
      @occupancy_grids[z] = grid

      grid.when :occupancy_change do |change_type,entity,x,y|
        @viewable_entities_dirty = 
          (@viewable_rows.include? entity.tile_x and 
          @viewable_cols.include? entity.tile_y)
        fire :occupancy_change, change_type, entity, x, y
      end

      @viewable_entities[z] = []
    end
    @z_entities[z] ||= []

    new_entity = klass.new(ent_id,
     {
      :resource_manager => @resource_manager,
      :sound_manager => @sound_manager,
      :viewport => @viewport,
      :entity_type => entity_type,
      :server_id => ent_id,
      :player_id => p_id,
      :occupancy_grid => @occupancy_grids[z],
      :map => @map,
      :entity_manager => self,
      :x => x,
      :y => y,
      :trace => @trace
     }
    )

    manage_entity new_entity
    new_entity
  end

  def update(time)
    # TODO PERF only call update on updatable ents?
    for entity in @id_entities.values
      entity.update(time)
    end
  end

  def update_viewable_tile_range()
    view_x = @viewport.x_offset
    view_y = @viewport.y_offset
    view_w = @viewport.width
    view_h = @viewport.height
    tl_tile = @map.coords_to_tiles view_x, view_y
    br_tile = @map.coords_to_tiles view_x+view_w, view_y+view_h

    x = [tl_tile[0]-1,0].max
    y = [tl_tile[1]-1,0].max
    w = br_tile[0]-x+1
    h = br_tile[1]-y+1
    @viewable_rows = (x..x+w-1)
    @viewable_cols = (y..y+h-1)
  end

  def map=(map)
    @map = map
    update_viewable_tile_range
    @viewport.when :screen_scroll do
      update_viewable_tile_range
      @viewable_entities_dirty = true
    end
  end

  def get_player_ents(p_id)
    p_ents = []
    pz_ents = @players_entities[p_id]
    pz_ents ||= {}
    pz_ents.values.flatten.uniq
  end

  def get_occupants_at(x,y,w=1,h=1,player=nil)
    occs = []
    for z,grid in @occupancy_grids
      if player
        occs << grid.get_occupants_by_player(x, y, w, h, player)
      else
        occs << grid.get_occupants(x, y, w, h)
      end
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
