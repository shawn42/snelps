require 'commands'
require 'publisher'
require 'base_mode'
require 'player'
require 'map'
require 'mini_map'
require 'occupancy_grid'
require 'story_dialog'
require 'inflector'
class CampaignMode < BaseMode
  extend Publisher
  include Commands

  can_fire :mode_change, :music_play, :music_stop, :sound_play,
    :network_msg_to

  attr_accessor :mini_map, :font_manager
  constructor :resource_manager, :font_manager, :entity_manager,
    :viewport, :snelps_screen, :network_manager, :mouse_manager,
    :entity_builder

  def setup()
    base_setup

    @entity_manager.when :sound_play do |snd|
      fire :sound_play, snd
    end
    @entity_manager.when :network_msg_to do |cmd|
      fire :network_msg_to, cmd
    end
    #TODO screen widths?
    @view_screen = Surface.new([824, 760])
    @background = Surface.new(@snelps_screen.size)

    @title_text = @font_manager.render(:excalibur, 30, "Snelps",true, LIGHT_GRAY)
    @resources_text = @font_manager.render(:excalibur, 10, "5/20       Vim: 20      Daub: 44",true, LIGHT_GRAY)

    @unscaled_warrior_image = 
      @resource_manager.load_image 'warrior_concept.png'
    @warrior_image = @unscaled_warrior_image.zoom([0.2,0.2],true).flip(true,false)
  end

  def on_key_up(event)
    case event.key
    when K_LEFT
      @viewport.jump :left
    when K_RIGHT
      @viewport.jump :right
    when K_UP
      @viewport.jump :up
    when K_DOWN
      @viewport.jump :down
    when K_Q
      fire :mode_change, :main_menu
    when K_ESCAPE
      fire :mode_change, :main_menu
    else
      @entity_manager.handle_key_up event
    end
  end

  def on_click(event)
    if @mini_map.hit_by? event.pos[0], event.pos[1]
      @mini_map.handle_mouse_click event
    else
      @entity_manager.handle_mouse_click event
    end
  end

  def on_mouse_dragging(x, y, event)
    if @mini_map.hit_by? event.pos[0], event.pos[1]
      @mini_map.handle_mouse_dragging event
    end
  end

  def on_mouse_motion(event)
    @viewport.scroll event
  end

  def on_mouse_drag(start_x,start_y,event)
    @entity_manager.handle_mouse_drag start_x, start_y, event
  end

  def on_network(event)
    # TODO, shouldn't do this, these should come from the turn manager
    # TODO can we break these down into target:method?
    pieces = event.split(':')
    case pieces[0]
    when ENTITY_CREATE
      @entity_manager.handle_create event
    when ENTITY_MOVE
      @entity_manager.handle_move event
    when ENTITY_ATTACK
      @entity_manager.handle_attack event
    when ENTITY_GATHER
      @entity_manager.handle_gather event
    when PLAYER_JOIN
      # parse player from event
      id = pieces[2].to_i
      snelp = Player::SNELPS[pieces[1].to_i]
      @player = Player.new :snelp => snelp, :server_id => id
    end
  end

  def start(*args)
    @map = nil
    fire :music_play, :background_music
    @campaign = @resource_manager.load_campaign(args.shift)
    @current_stage = @campaign[:stages].shift

    modal_dialog StoryDialog, @current_stage[:before_story] do |d|
      start_play
    end

  end

  def stop(*args)
    fire :music_stop, :background_music
  end

  def start_play()
    #TODO get this from main_menu_mode
    # lets make the player a fire snelp
    snelp_index = Player::SNELPS.index :fire
    player_cmd = "#{PLAYER_JOIN}:#{snelp_index}"

    fire :network_msg_to, player_cmd
    
    map_name = @current_stage[:map]
    @map = Map.load_from_file @resource_manager, map_name
    
    @viewport.setup
    @viewport.set_map_size(@map.pixel_width, @map.pixel_height)
    @map.viewport = @viewport

    @entity_manager.setup

    @entity_manager.map = @map

    @map.entity_manager = @entity_manager
    @entity_manager.setup

    @mini_map = MiniMap.new @map, @viewport, @entity_manager
    @mini_map.when :center_viewport do |x,y|
      @viewport.center_to x, y
    end

    @map.script.when :victory do
      # TODO add summary report page?
      p "VICTORY"
      fire :mode_change, :main_menu
    end

    @map.script.when :create_entity do |ent_type,player,tile_x,tile_y|
      x, y = @map.tiles_to_coords(tile_x,tile_y)
      # TODO, is there a better way of getting the z here?
      klass = Object.const_get Inflector.camelize(ent_type)
      z = klass.default_z

      if @entity_manager.has_obstacle?(tile_x, tile_y, z)
        raise "obstacle: invalid map script #{player} #{ent_type} #{tile_x},#{tile_y},#{z}"
      else
        cmd = @entity_manager.create_entity_cmd(player,ent_type,x,y)
        @network_manager[:to_server] << cmd
      end
    end

    @map.start_script
    @playing = true
  end

  def update(time)
    return unless @playing
    @mini_map.update time unless @mini_map.nil?
    @map.update time unless @map.nil?
    @viewport.update time unless @viewport.nil?
    @entity_manager.update time unless @entity_manager.nil?
  end
  
  def draw(destination)
    return unless @playing

    @background.blit destination, [0,0]

    @map.draw @view_screen unless @map.nil?
    @entity_manager.draw @view_screen unless @entity_manager.nil?

    @view_screen.blit destination, [10,36]

    @mouse_manager.draw destination

    destination.draw_box_s([0, 35], [10, 800], LIGHT_PURPLE)
    destination.draw_box_s([10, 794], [1024, 800], LIGHT_PURPLE)
    destination.draw_box_s([824, 35], [1024, 794], LIGHT_PURPLE)
    destination.draw_box_s([0, 0], [1024, 35], LIGHT_PURPLE)

    @mini_map.draw destination unless @mini_map.nil?
    
    #outline
    destination.draw_box([1, 1], [1023, 34], PURPLE)
    @warrior_image.blit(destination,[800,10])
    @title_text.blit(destination,[60,1])
    @resources_text.blit(destination,[630,20])
  end

  def key_up(event)
    case event.key
    when K_Q
      fire :mode_change, :main_menu
    when K_ESCAPE
      fire :mode_change, :main_menu
    end
  end

end
