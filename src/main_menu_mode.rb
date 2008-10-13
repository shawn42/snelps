require 'rubygoo'
require 'publisher'
require 'button'
require 'settings_dialog'
require 'base_mode'
require 'absolute_layout'
class MainMenuMode < Rubygoo::Container #BaseMode
  extend Publisher

  attr_accessor :font_manager, :modal_dialogs, :x, :y
  can_fire :mode_change, :music_play, :music_stop, :sound_play,
    :network_msg_to, :config_manager

#  constructor :resource_manager, :font_manager, :snelps_screen,
#    :config_manager
  def initialize(opts)
    @resource_manager = opts[:resource_manager]
    @font_manager = opts[:font_manager]
    @snelps_screen = opts[:snelps_screen]
    @config_manager = opts[:config_manager]
    super
    setup
  end

  #TODO screen widths?
  def setup()
    base_setup
    @background = Surface.new(@snelps_screen.size)

    @title_text = 
      @font_manager.render :excalibur, 70, "Snelps",true, LIGHT_GRAY

    @unscaled_warrior_image = 
      @resource_manager.load_image 'warrior_concept.png'
    @warrior_image = @unscaled_warrior_image.zoom([0.4,0.4],true)

    @layout = AbsoluteLayout.new self, @font_manager
    button = Button.new @layout, "Campaign" do |b|
      fire :mode_change, :campaign_play, "snelps"
    end
    @layout.add button, 150, 550

    button = Button.new @layout, "Quit" do |b|
      throw :rubygame_quit
    end

    @layout.add button, 712, 550

    button = Button.new @layout, "Settings" do |b|
      settings = @config_manager.settings.dup
      modal_dialog SettingsDialog, settings do |d|
        @config_manager[:fullscreen] = d.settings[:fullscreen]
        @config_manager[:sound] = d.settings[:sound]
        @config_manager.save
      end
    end
    @layout.add button, 450, 550
  end

  def on_click(event)
    @layout.click(event)
  end

  def on_mouse_dragging(x,y,event)
    @layout.mouse_dragging(x,y,event)
  end

  def on_mouse_motion(event)
    @layout.mouse_motion(event)
  end

  def on_key_up(event)
    case event.data[:key]
    when K_Q
      throw :rubygame_quit
    when K_ESCAPE
      throw :rubygame_quit
    end
  end

  def update(time)
  end

  def start(*args)
    fire :music_play, :menu_music
  end

  def stop(*args)
    fire :music_stop, :menu_music
  end
  
  def draw(destination)

    @background.blit destination, [0,0]
    @layout.draw destination

    @warrior_image.blit(destination,[300,90])
    @title_text.blit(destination,[360,10])

#    @app_adapter.draw destination

  end
  
  # copied in from base mode for now:

  def base_setup()
    @x = 0 unless @x
    @y = 0 unless @y
    @modal_dialogs ||= []
  end

  def modal_dialog(klass, *args, &block)
    md = klass.new(self, *args)
    md.on_close = block if block_given?
    md.when :destroy_modal_dialog do |d|
      @modal_dialogs.pop
      if d.apply?
        d.close_callback
      end
    end
    @modal_dialogs << md
    end

  def fire_or_dispatch_to_modal(event_name, *args)
    target = @modal_dialogs.empty? ? self : @modal_dialogs.first
    target.send "on_#{event_name}", *args
  end

  # called by controller
  def handle_key_up(event)
    fire_or_dispatch_to_modal :key_up, event
  end

  def handle_click(event)
    fire_or_dispatch_to_modal :click, event
  end

  def handle_mouse_motion(event)
    fire_or_dispatch_to_modal :mouse_motion, event
  end

  def handle_mouse_dragging(*args)
    fire_or_dispatch_to_modal :mouse_dragging, *args
  end

  def handle_mouse_drag(*args)
    fire_or_dispatch_to_modal :mouse_drag, *args
  end

  def handle_network(event)
    fire_or_dispatch_to_modal :network, event
  end

  def handle_draw(dest)
    @modal_dialogs ||= []
    draw(dest)
    unless @modal_dialogs.empty?
      @modal_dialogs.each do |md|
        md.draw dest
      end
    end
  end

end
