require 'publisher'
require 'base_mode'
require 'player'
require 'map'
require 'fog'
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
    @players ||= []
    @entity_manager.players = @players

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

    @unit_info_text = @font_manager.render(:excalibur, 10, "5/20",true, LIGHT_GRAY)
    @vim_text = @font_manager.render(:excalibur, 10, "Vim: 20",true, LIGHT_GRAY)
    @daub_text = @font_manager.render(:excalibur, 10, "Daub: 44",true, LIGHT_GRAY)

    @unscaled_warrior_image = 
      @resource_manager.load_image 'warrior_concept.png'
    @warrior_image = @unscaled_warrior_image.zoom([0.2,0.2],true).flip(true,false)
  end

  def on_key_up(event)
    case event.data[:key]
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
    if @mini_map and @mini_map.hit_by? event.data[:x], event.data[:y]
      @mini_map.handle_mouse_click event
    else
      @entity_manager.handle_mouse_click event
    end
  end

  def on_mouse_dragging(x, y, event)
    if @mini_map and @mini_map.hit_by? event.data[:x], event.data[:y]
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
    cmd = pieces[0]
    case cmd
    when PLAYER_JOIN
      # parse player from event
      id = pieces[2].to_i
      snelp = Player::SNELPS[pieces[1].to_i]
      local = true if pieces[3] == "L"

      player = Player.new :snelp => snelp, :server_id => id, :local => local
      player.setup
      @players << player

      @local_player = player if local
    else
      target_pieces = pieces[0].split('_')
      prefix = target_pieces[0]
      case prefix
      when ENTITY_PREFIX
#        case cmd
#        when ENTITY_CREATE
#          @entity_manager.handle_create event
#        when ENTITY_MOVE
#          @entity_manager.handle_move event
#        when ENTITY_MELEE_ATTACK
#          @entity_manager.handle_attack event
#        when ENTITY_GATHER
#          @entity_manager.handle_gather event
#        else
          @entity_manager.handle event
#        end
      else
        p "unknown network event: [#{prefix} - #{cmd} - #{event}]"
      end
    end
  end

  def start(*args)
    @map = nil

    @campaign = @resource_manager.load_campaign(args.shift)
    fire :music_play, :background_music

    @current_stage = @campaign[:stages].shift
    campaign_step @current_stage
  end

  def campaign_step(stage)
    @playing = false

    modal_dialog StoryDialog, stage[:before_story] do |d|
      start_next_map stage
    end
  end

  def stop(*args)
    fire :music_stop, :background_music
    @playing = false
#    @snelps_screen.show_cursor = true
  end

  def start_next_map(stage)

#    @snelps_screen.show_cursor = false

    #TODO get this from main_menu_mode
    # lets make the player a fire snelp
    player_cmd = Player.create_player_cmd :fire
    fire :network_msg_to, player_cmd
    
    map_name = stage[:map]
    @map = Map.load_from_file @resource_manager, map_name
    
    @viewport.setup
    @viewport.set_map_size(@map.pixel_width, @map.pixel_height)
    @map.viewport = @viewport

    @entity_manager.map = @map

    @map.entity_manager = @entity_manager
    @entity_manager.setup
    @fog = Fog.new @map, @entity_manager, @viewport, @resource_manager

    @mini_map = MiniMap.new @map, @viewport, @entity_manager
    @mini_map.when :center_viewport do |x,y|
      @viewport.center_to x, y
    end

    @map.script.when :victory do
      # TODO add summary report page?
      p "VICTORY"

      @current_stage = @campaign[:stages].shift
      if @current_stage.nil?
        fire :mode_change, :main_menu
      else
        campaign_step @current_stage
      end
    end

    @map.script.when :defeat do
      # TODO add summary report page?
      p "DEFEAT"
#      fire :mode_change, :main_menu
    end

    @map.script.when :create_entity do |player,ent_type,tile_x,tile_y|
      # TODO, is there a better way of getting the z here?
      klass = Object.const_get Inflector.camelize(ent_type)
      z = klass.default_z

      if @entity_manager.has_obstacle?(tile_x, tile_y, z)
        raise "obstacle: invalid map script #{player} #{ent_type} #{tile_x},#{tile_y},#{z}"
      else
        cmd = @entity_manager.create_entity_cmd(player,ent_type,tile_x,tile_y)
        @network_manager[:to_server] << cmd
      end
    end

    @map.script.when :create_player do |snelp,player_type|
      cmd = Player.create_player_cmd snelp, player_type
      @network_manager[:to_server] << cmd
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

    # TODO, cache these trigger the re-render based on events
    vim = 0
    daub = 0
    vim = @local_player.vim if @local_player
    daub = @local_player.daub if @local_player
    @vim_text = @font_manager.render(:excalibur, 10, "Vim: #{vim}",true, LIGHT_GRAY)
    @daub_text = @font_manager.render(:excalibur, 10, "Daub: #{daub}",true, LIGHT_GRAY)

    @unit_info_text = @font_manager.render(:excalibur, 10, "5/20",true, LIGHT_GRAY)
  end
  
  def draw(destination)
    return unless @playing

    @background.blit destination, [0,0]

    # TODO move all this to a layout of somekind?
    # maybe finally bite the bullet and switch to rubygoo?
#    @layout = AbsoluteLayout.new self, @font_manager
#    button = Button.new @layout, "Campaign" do |b|
#      fire :mode_change, :campaign_play, "snelps"
#    end
#    @layout.add button, 150, 550
#
#    info_bar = Container.new

    @map.draw @view_screen unless @map.nil?
    @entity_manager.draw @view_screen unless @entity_manager.nil?

    @view_screen.blit destination, [10,36]

    @fog.draw destination

    destination.draw_box_s([0, 35], [10, 800], LIGHT_PURPLE)
    destination.draw_box_s([10, 794], [1024, 800], LIGHT_PURPLE)
    destination.draw_box_s([824, 35], [1024, 794], LIGHT_PURPLE)
    destination.draw_box_s([0, 0], [1024, 35], LIGHT_PURPLE)

    @mini_map.draw destination unless @mini_map.nil?
    
    @fog.draw_minimap_fog destination

    #outline
    destination.draw_box([1, 1], [1023, 34], PURPLE)
    @warrior_image.blit(destination,[800,10])
    @title_text.blit(destination,[60,1])
    @unit_info_text.blit(destination,[630,20])
    @vim_text.blit(destination,[680,20])
    @daub_text.blit(destination,[730,20])

    @mouse_manager.draw destination

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
