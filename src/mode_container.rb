require 'rubygoo'
require 'publisher'
require 'campaign_mouse_view'
class ModeContainer < Rubygoo::Container
  extend Publisher

  can_fire :start_game, :resized

  def initialize(opts)
    @resource_manager = opts[:resource_manager]
    @font_manager = opts[:font_manager]
    @sound_manager = opts[:sound_manager]
    @network_manager = opts[:network_manager]
    @turn_manager = opts[:turn_manager]
    @snelps_screen = opts[:snelps_screen]
    @campaign_mode = opts[:campaign_mode]
    @intro_mode = opts[:intro_mode]
    @main_menu_mode = opts[:main_menu_mode]
    @mouse_manager = opts[:mouse_manager]

    @mouse_view = CampaignMouseView.new :mouse => @mouse_manager,
      :resource_manager => @resource_manager
      
    super :w => @snelps_screen.size[0], 
      :h => @snelps_screen.size[1]
    setup

    add @main_menu_mode, @intro_mode
  end

  # XXX this feels like a hack, where should this really go?
  # should I subscribe to myself for :added event?
  def added()
    super
    self.app.mouse = @mouse_view
  end

  def key_released(evt)
    dispatch_mode_event :handle_key_up, evt
  end

  def mouse_down(evt)
    @mouse_manager.mouse_down evt
  end

  def mouse_up(evt)
    @mouse_manager.mouse_up evt
    dispatch_mode_event :handle_click, evt
  end

  def mouse_drag(evt)
    @mouse_manager.mouse_up evt
    dispatch_mode_event :handle_mouse_drag, @mouse_manager.start_x,@mouse_manager.start_y, evt
  end

  def mouse_motion(evt)
    @mouse_manager.mouse_motion evt
    dispatch_mode_event :handle_mouse_motion, evt
  end

  def mouse_dragging(evt)
    @mouse_manager.mouse_motion evt
    dispatch_mode_event :handle_mouse_dragging, @mouse_manager.start_x,@mouse_manager.start_y, evt
  end

  def setup()
    @modes = {}
    @modes[:main_menu] = @main_menu_mode
    @modes[:campaign_play] = @campaign_mode
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

    @network_manager[:from_server].when :msg_received do |e| dispatch_mode_event :handle_network, e end
  
    change_mode_to :intro
  end

  def dispatch_mode_event(name, *args)
    @modes[@mode].send(name, *args) if @mode == :campaign_play
  end
  
  def change_mode_to(mode, *args)
    @modes[@mode].stop unless @modes[@mode].nil?
    @mode = mode
    @modes[@mode].start *args
  end

  def update(time)
    @modes[@mode].update time if @mode == :campaign_play
  end

  def draw(renderer)
    if @mode == :campaign_play
      @modes[@mode].handle_draw @snelps_screen.screen 
    end
  end

  def focussed?()
    true
  end

end
