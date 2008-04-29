require 'commands'
require 'publisher'
require 'base_mode'
require 'player'
require 'map'
require 'mini_map'
require 'occupancy_grid'
require 'story_dialog'
class CampaignMode < BaseMode
  extend Publisher
  include Commands

  can_fire :mode_change, :music_play, :music_stop, :sound_play,
    :network_msg_to

  attr_accessor :mini_map, :font_manager
  constructor :resource_manager, :font_manager, :entity_manager,
    :viewport, :snelps_screen, :network_manager, :animation_manager,
    :mouse_manager, :entity_builder

  def setup()
    base_setup

    @entity_manager.when :sound_play do |snd|
      fire :sound_play, snd
    end
    @entity_manager.when :network_msg_to do |cmd|
      fire :network_msg_to, cmd
#      @network_manager[:to_server].push cmd
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
    when K_Q
      fire :mode_change, :main_menu
    when K_ESCAPE
      fire :mode_change, :main_menu
    else
      @entity_manager.handle_key_up event
    end
  end

  def on_click(event)
    @entity_manager.handle_mouse_click event
  end

  def on_mouse_motion(event)
    @viewport.scroll event
  end

  def on_mouse_drag(start_x,start_y,event)
    @entity_manager.handle_mouse_drag start_x, start_y, event
  end

  def on_network(event)
    # TODO, shouldn't do this, these should come from the turn manager
    pieces = event.split(':')
    case pieces[0]
    when ENTITY_MOVE
      @entity_manager.handle_entity_move event
    when PLAYER_JOIN
      # parse player from event
      id = pieces[2].to_i
      snelp = Player::SNELPS[pieces[1].to_i]
      p "creating player..."
      @player = Player.new :snelp => snelp, :server_id => id
    end
  end

  def start(*args)
    fire :music_play, :ingame_background
    @campaign = @resource_manager.load_campaign(args.shift)
    @current_stage = @campaign[:stages].shift

    modal_dialog StoryDialog, @current_stage[:before_story] do |d|
      start_play
    end

  end

  def stop(*args)
    fire :music_stop, :ingame_background
  end

  def start_play()
    @entity_manager.setup

    #TODO get this from main_menu_mode
    # lets make the player a fire snelp
    snelp_index = Player::SNELPS.index :fire
    player_cmd = "#{PLAYER_JOIN}:#{snelp_index}"

    fire :network_msg_to, player_cmd
    
    map_name = @current_stage[:map]
    @map = Map.load_from_file @resource_manager, map_name

    @map.when :victory do
      p "VICTORY!!"
      fire :mode_change, :main_menu
    end
    @map.when :failure do
      p "FAILURE!!"
      fire :mode_change, :main_menu
    end
    
    @viewport.set_map_size(@map.pixel_width, @map.pixel_height)
    @map.viewport = @viewport

    @entity_manager.map = @map
    @entity_manager.entities = []

    # putting this here because mini_map may benifit from having these
    # as well
    @occupancy_grids = {}
    @occupancy_grids[:flying] = OccupancyGrid.new @map.width, @map.height
    @occupancy_grids[:ground] = OccupancyGrid.new @map.width, @map.height
    @entity_manager.occupancy_grids = @occupancy_grids

    @mini_map = MiniMap.new @map, @viewport, @entity_manager

    @playing = true
    # TODO take this out?
    setup_test_units
    # fake out to pump turn events
#    @turn_manager.start self
  end

  def setup_test_units()
    num_test_ents = 30
    Thread.new do
      sleep 1
      ents = []
      num_test_ents.times do
        created = false 
        type = [:unit_worker,:unit_bird][rand(2)]
        until created do
          x,y = rand(@map.pixel_width), rand(@map.pixel_height)
          tile_x, tile_y = @map.coords_to_tiles(x,y)
          unless @entity_manager.has_obstacle?(tile_x, tile_y, type) 
            ents << @entity_manager.create_entity(type,x,y)
            created = true
          end
        end
      end
      p "setup #{num_test_units} entities ... lets see em dance"
      loop do
        begin
          for entity in ents
            if entity.idle?
              x = rand(@map.w)
              y = rand(@map.h)
              cmd = "#{ENTITY_MOVE}:#{entity.server_id}:#{x}:#{y}"
              fire :network_msg_to, cmd
            end
          end
          sleep 5
        rescue Exception => ex
          p "boom"
          p ex
        end
      end
    end
  end

  def update(time)
    return unless @playing
    @mini_map.update time unless @mini_map.nil?
    @map.update time unless @map.nil?
    @viewport.update time unless @viewport.nil?
    @animation_manager.update time unless @animation_manager.nil?
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
