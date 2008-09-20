require 'pathfinder_ll'
require 'publisher'
require 'commands'
require 'entity'
require 'entity_selection'
class EntityManager
  extend Publisher
  include Commands

  attr_accessor :map, :occupancy_grids, :current_selection, 
    :selections, :current_abilities, :base_entities, :players

  can_fire :sound_play, :network_msg_to

  constructor :viewport, :resource_manager, :sound_manager, :network_manager,
    :mouse_manager, :input_manager, :ability_manager 
  
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
  end

  def find_entity_by_id(server_id)
    @id_entities[server_id]
  end

  def handle_attack(cmd)
    fire :sound_play, :ent_attack
    attack_cmd,entity_id,tile_x,tile_y = cmd.split ':'
    ent = @id_entities[entity_id.to_i]
    # if targetable ent is at x, y
    ents = get_occupants_at(tile_x.to_i, tile_y.to_i)
    targetable_ents = ents.select{|e|e.player_id != 1}
    if targetable_ents.empty?
      # TODO set aggressive mode?
      ent.melee_attack :target => [tile_x,tile_y]
    else
      ent.melee_attack :target => targetable_ents.first
    end
  end

  def handle_gather(cmd)
    fire :sound_play, :ent_gather
    attack_cmd,entity_id,tile_x,tile_y = cmd.split ':'
    ent = @id_entities[entity_id.to_i]
    
    # if targetable ent is at x, y
    ents = get_occupants_at(tile_x.to_i, tile_y.to_i).select{|e|e.is? :providable}
    if ents.empty?
      # TODO set looking mode?
      ent.gather :target => [tile_x,tile_y]
    else
      ent.gather :target => ents.first
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
    # seems like a bad place for this
    entity.cancel_all_attacks if entity.is? :melee_attacker

    entity.path_to dest_tile_x, dest_tile_y if entity.is? :pathable
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
    case event.key
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
    when K_T
      @trace = !@trace
      for entity in @id_entities.values
        entity.trace = @trace
      end
    when K_R
      require 'MemoryProfiler'
    when K_N
      # TODO create random wandering ent
      begin
        10.times do
          w = rand(@map.width)
          h = rand(@map.height)
          @map.script.create_entity :animal, nil, w, h
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

        world_x, world_y = @viewport.view_to_world(x, y)

        tile_x,tile_y = 
          @map.coords_to_tiles(world_x,world_y)

        target = [tile_x,tile_y]

        targets = get_occupants_at(tile_x, tile_y)
        if targets.size > 0
          target = targets.first
        end

        act = entity.actions(:target=>target).first

        cmd = "ENT_#{act.to_s.upcase}:#{entity.server_id}:#{tile_x}:#{tile_y}"
        fire :network_msg_to, cmd
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
        grid = OccupancyGrid.new @map.width, @map.height
        @occupancy_grids[z] = grid

        grid.when :occupancy_change do |change_type,entity|
          @viewable_entities_dirty = 
            (@viewable_rows.include? entity.tile_x and 
            @viewable_cols.include? entity.tile_y)
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

      @players_entities[p_id] ||= {}
      @players_entities[p_id][z] ||= []
      @players_entities[p_id][z] << new_entity
      @z_entities[z] << new_entity
      @id_entities[ent_id] = new_entity

      # TODO, un hardcode the player id
      @base_entities[ent_id] = new_entity if new_entity.is?(:collector) and new_entity.player_id == 1

      new_entity.animate if new_entity.is? :animated
      if new_entity.is? :livable
        new_entity.when :death do |ent|
          p "entity[#{ent.server_id}] died"

          @viewable_entities[ent.z].delete ent
          @players_entities[ent.player_id][ent.z].delete ent

          @z_entities[ent.z].delete ent
          @id_entities.delete ent.server_id
          @base_entities.delete ent.server_id
          ent.unsubscribe :death, self
        end
      end
    rescue Exception => ex
      p ex
      caller.each do |c|
        p c
      end
    end
    new_entity
  end

  def update(time)
    # TODO PERF only call update on updatable ents?
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
      if @viewable_entities_dirty
        @viewable_entities[az] = []
        @occupancy_grids[az].get_occupants_by_range(@viewable_rows,@viewable_cols).each do |ze|
          @viewable_entities[az] << ze
        end
      end
      for ze in @viewable_entities[az]
        ze.draw destination
      end
    end
    # TODO any race conditions here??
    @viewable_entities_dirty = false 
  end

  def update_viewable_tile_range()
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
