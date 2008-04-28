require 'publisher'
class ModeController
  extend Publisher

  can_fire :start_game

  attr_accessor :state
  constructor :resource_manager, :font_manager, :sound_manager, :input_manager,
    :network_manager, :turn_manager, :mouse_manager, :snelps_screen,
    :campaign_mode, :main_menu_mode

  def setup()
    # TODO put this somewhere else?
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
    @input_manager.when :key_up do |e| dispatch_mode_event :handle_key_up, e end
    @mouse_manager.when :mouse_motion do |e| dispatch_mode_event :handle_mouse_motion, e end
    @mouse_manager.when :mouse_drag do |x,y,e| dispatch_mode_event :handle_mouse_drag, x, y, e end
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
    @snelps_screen.update
    draw
  end

  def draw()
    @modes[@mode].handle_draw @snelps_screen.screen
  end

end
