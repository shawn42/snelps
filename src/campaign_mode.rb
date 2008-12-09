require 'rubygoo'
require 'publisher'
require 'player'
require 'map'
require 'fog'
require 'mini_map'
require 'gameplay_view'
require 'mini_map_view'

class CampaignMode < Rubygoo::Container
  extend Publisher
  include Commands

  can_fire :mode_change, :music_play, :music_stop, :sound_play,
    :network_msg_to

  def initialize(opts)
    @resource_manager = opts[:resource_manager]
    @config_manager = opts[:config_manager]
    @entity_manager = opts[:entity_manager]
    @viewport = opts[:viewport]
    @network_manager = opts[:network_manager]
    @entity_builder = opts[:entity_builder]

    opts[:visible] = false
    opts[:enabled] = false
    super opts

    setup
    build_gui
  end

  def setup()
    @players ||= []
    @entity_manager.players = @players

    @entity_manager.when :sound_play do |snd|
      fire :sound_play, snd
    end
    @entity_manager.when :network_msg_to do |cmd|
      fire :network_msg_to, cmd
    end
  end

  def build_gui()

    # ACTUAL GAMEPLAY
    @gameplay_view = GameplayView.new(:x=>10,:y=>30, :visible=>false)
    add @gameplay_view

    # GUI LABELS
    add Rubygoo::Label.new("Snelps", :x=>60)
    add Rubygoo::Label.new("5/20", :x=>630, :y=>20, :font_size=>10)
    add Rubygoo::Label.new("Vim 200", :x=>680, :y=>20, :font_size=>10)
    add Rubygoo::Label.new("Daub 200", :x=>730, :y=>20, :font_size=>10)

    # MINIMAP
    @mini_map_view = MiniMapView.new :x=>850, :y=>150, :visible=>false
    add @mini_map_view

    @unscaled_warrior_image = 
      @resource_manager.load_image 'warrior_concept.png'
    @warrior_image = @unscaled_warrior_image.zoom([0.2,0.2],true).flip(true,false)
    add Rubygoo::Icon.new(:icon=>@warrior_image,:x=>800)


    scroll_w = Viewport::ACTIVE_EDGE_WIDTH
    # scrolling hotspots
    scroll_right = Rubygoo::Widget.new :x=>989,:y=>0,
      :w=>scroll_w,:h=>800
    # TODO update publisher to allow easier hooking of many events to one callback
    scroll_right.when :mouse_exit do |evt|
      @viewport.vx = 0
    end
    scroll_right.when :mouse_motion do |evt|
      if scroll_right.mouse_over?
        @viewport.vx += Viewport::SCROLL_SPEED
      end
    end
    scroll_left = Rubygoo::Widget.new :x=>0,:y=>0,
      :w=>scroll_w,:h=>800
    scroll_left.when :mouse_exit do |evt|
      @viewport.vx = 0
    end
    scroll_left.when :mouse_motion do |evt|
      if scroll_left.mouse_over?
        @viewport.vx -= Viewport::SCROLL_SPEED
      end
    end
    scroll_up = Rubygoo::Widget.new :x=>0,:y=>0,
      :w=>1024,:h=>scroll_w
    scroll_up.when :mouse_exit do |evt|
      @viewport.vy = 0
    end
    scroll_up.when :mouse_motion do |evt|
      if scroll_up.mouse_over?
        @viewport.vy -= Viewport::SCROLL_SPEED
      end
    end
    scroll_down = Rubygoo::Widget.new :x=>0,:y=>765,
      :w=>1024,:h=>scroll_w
    scroll_down.when :mouse_exit do |evt|
      @viewport.vy = 0
    end
    scroll_down.when :mouse_motion do |evt|
      if scroll_down.mouse_over?
        @viewport.vy += Viewport::SCROLL_SPEED
      end
    end

    add scroll_right, scroll_left, scroll_up, scroll_down
  end

  def update(time)
    @viewport.update time if @viewport
  end

  def key_released(event)
    case event.data[:key]
    when K_LEFT
      @viewport.jump :left
    when K_RIGHT
      @viewport.jump :right
    when K_UP
      @viewport.jump :up
    when K_DOWN
      @viewport.jump :down
    when K_ESCAPE
      fire :mode_change, :main_menu
    else
      @entity_manager.handle_key_up event
    end
  end

  def start(*args)
    @map = nil

    @campaign = @resource_manager.load_campaign(args.shift)
    fire :music_play, :background_music

    @current_stage = @campaign[:stages].shift
    campaign_step @current_stage

    self.show

  end

  def campaign_step(stage)
    #    TODO RUBYGOO DIALOG
#    modal_dialog StoryDialog, stage[:before_story] do |d|
      start_next_map stage
#    end
  end

  def start_next_map(stage)

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

#    @abilities_panel = AbilitiesPanel.new self, :x=>835,:y=>350,:w=>180,:h=>300


    @fog = Fog.new @map, @entity_manager, @viewport, @resource_manager

    @mini_map = MiniMap.new @map, @viewport, @entity_manager
    @mini_map.when :center_viewport do |x,y|
      @viewport.center_to x, y
    end

    @mini_map.fog = @fog

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

    # GUI STUFF
    @gameplay_view.map = @map
    @gameplay_view.viewport = @viewport
    @gameplay_view.entity_manager = @entity_manager
    @gameplay_view.fog = @fog

    @mini_map_view.mini_map = @mini_map

    @map.start_script
    @gameplay_view.show
    @mini_map_view.show
  end

  def on_network(event)
    # TODO, shouldn't do this, these should come from the turn manager
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
        @entity_manager.handle event
      else
        p "unknown network event: [#{prefix} - #{cmd} - #{event}]"
      end
    end
  end


  def stop(*args)
    fire :music_stop, :background_music
    self.hide
  end

  def focussed?()
    true
  end
end
