require 'rubygoo'
require 'publisher'
require 'campaign_mouse_view'
class ModeContainer < Rubygoo::Container
  extend Publisher

  can_fire :start_game

#  constructor :resource_manager, :font_manager, :sound_manager, :input_manager,
#    :network_manager, :turn_manager, :mouse_manager, :snelps_screen,
#    :campaign_mode, :main_menu_mode

  # TODO do I need these?
  def initialize(opts)
    @resource_manager = opts[:resource_manager]
    @font_manager = opts[:font_manager]
    @sound_manager = opts[:sound_manager]
    @network_manager = opts[:network_manager]
    @turn_manager = opts[:turn_manager]
    @snelps_screen = opts[:snelps_screen]
    @campaign_mode = opts[:campaign_mode]
    @main_menu_mode = opts[:main_menu_mode]
    @mouse_manager = opts[:mouse_manager]

    @mouse_view = CampaignMouseView.new :mouse => @mouse_manager,
      :resource_manager => @resource_manager
      

    super :w => @snelps_screen.size[0], 
      :h => @snelps_screen.size[1]
    setup
    add @mouse_view
  end

  def key_pressed(evt)
    dispatch_mode_event :handle_key_up, evt
  end

  def mouse_down(evt)
    @mouse_manager.mouse_down evt
    dispatch_mode_event :handle_click, evt
  end

  def mouse_up(evt)
    @mouse_manager.mouse_up evt
  end

  def mouse_motion(evt)
    @mouse_manager.mouse_motion evt
  end

  def setup()
    @modes = {}
    @modes[:main_menu] = @main_menu_mode
    @modes[:campaign_play] = @campaign_mode

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

    # TODO standardize these names
    @mouse_manager.when :mouse_motion do |e| dispatch_mode_event :handle_mouse_motion, e end
    @mouse_manager.when :mouse_drag do |x,y,e| dispatch_mode_event :handle_mouse_drag, x, y, e end
    @mouse_manager.when :mouse_dragging do |x,y,e| dispatch_mode_event :handle_mouse_dragging, x, y, e end
    @mouse_manager.when :mouse_click do |e| dispatch_mode_event :handle_click, e end
    @network_manager[:from_server].when :msg_received do |e| dispatch_mode_event :handle_network, e end
  
    change_mode_to :main_menu
  end

  def dispatch_mode_event(name, *args)
    @modes[@mode].send(name, *args)
  end
  
  def change_mode_to(mode, *args)
    @modes[@mode].stop unless @modes[@mode].nil?
    @mode = mode
    @modes[@mode].start *args
  end

  def update(time)
    @modes[@mode].update time
  end

  def draw(renderer)
    @modes[@mode].handle_draw @snelps_screen.screen

    super renderer
#    @snelps_screen.flip
  end

end
