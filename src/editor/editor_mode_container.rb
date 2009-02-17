require 'rubygoo'
require 'publisher'
require 'editor_mouse_view'
class ModeContainer < Rubygoo::Container
  extend Publisher

  can_fire :start_game, :resized

  def initialize(opts)
    @snelps_screen = opts[:snelps_screen]
    super :w => @snelps_screen.size[0], 
      :h => @snelps_screen.size[1]

    @resource_manager = opts[:resource_manager]
    @sound_manager = opts[:sound_manager]

    @editor_mode = opts[:editor_mode]
    @editor_mode.w=@w
    @editor_mode.h=@h

    @mouse_manager = opts[:mouse_manager]

    @mouse_view = EditorMouseView.new :mouse => @mouse_manager,
      :resource_manager => @resource_manager
      
    add @editor_mode

    setup
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
    @modes[:editor] = @editor_mode

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
    end
  
  end

  def start
    change_mode_to :editor
  end

  def key_released(event)
    start if @mode.nil?
  end

  def mouse_up(event)
    start if @mode.nil?
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
