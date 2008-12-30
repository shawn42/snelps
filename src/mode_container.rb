require 'rubygoo'
require 'publisher'
require 'campaign_mouse_view'
class ModeContainer < Rubygoo::Container
  extend Publisher

  can_fire :start_game, :resized

  def initialize(opts)
    @snelps_screen = opts[:snelps_screen]
    super :w => @snelps_screen.size[0], 
      :h => @snelps_screen.size[1]

    @resource_manager = opts[:resource_manager]
    @sound_manager = opts[:sound_manager]
    @network_manager = opts[:network_manager]
    @turn_manager = opts[:turn_manager]

    @campaign_mode = opts[:campaign_mode]
    @campaign_mode.w=@w
    @campaign_mode.h=@h
    
    @multiplayer_mode = opts[:multiplayer_mode]
    @multiplayer_mode.w=@w
    @multiplayer_mode.h=@h
    
    @intro_mode = opts[:intro_mode]
    @intro_mode.w=@w
    @intro_mode.h=@h
    @main_menu_mode = opts[:main_menu_mode]
    @main_menu_mode.w=@w
    @main_menu_mode.h=@h

    @mouse_manager = opts[:mouse_manager]

    @mouse_view = CampaignMouseView.new :mouse => @mouse_manager,
      :resource_manager => @resource_manager
      
    setup

    add @main_menu_mode, @intro_mode, @campaign_mode, @multiplayer_mode
  end

  # XXX this feels like a hack, where should this really go?
  # should I subscribe to myself for :added event?
  def added()
    super
    self.app.mouse = @mouse_view
  end

  def mouse_down(evt)
    @mouse_manager.mouse_down evt
  end

  def mouse_up(evt)
    @mouse_manager.mouse_up evt
  end

  def mouse_drag(evt)
    @mouse_manager.mouse_up evt
  end

  def mouse_motion(evt)
    @mouse_manager.mouse_motion evt
  end

  def mouse_dragging(evt)
    @mouse_manager.mouse_motion evt
  end

  def setup()
    @modes = {}
    @modes[:main_menu] = @main_menu_mode
    @modes[:campaign_play] = @campaign_mode
    @modes[:multi_play] = @multiplayer_mode
    @modes[:intro] = @intro_mode

    @modes.each do |k,m|
      m.when :mode_change do |new_mode,*args|
        change_mode_to new_mode, *args
      end
      m.when :music_play do |music_key|
        @sound_manager.play music_key
      end
      m.when :music_stop do |music_key|
        @sound_manager.stop music_key
      end
      m.when :sound_play do |sound_key|
        @sound_manager.play_sound sound_key
      end
      m.when :network_msg_to do |cmd|
        @network_manager[:to_server].push cmd
      end
    end

    @network_manager[:from_server].when :msg_received do |e| 
      @modes[@mode].on_network e 
    end
  
    change_mode_to :intro
  end

  def change_mode_to(mode, *args)
    @modes[@mode].stop unless @modes[@mode].nil?
    @mode = mode
    @modes[@mode].start *args
  end

  def focussed?()
    true
  end

end
