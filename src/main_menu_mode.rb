require 'publisher'
require 'button'
require 'settings_dialog'
require 'base_mode'
require 'absolute_layout'
class MainMenuMode < BaseMode
  extend Publisher

  attr_accessor :font_manager
  can_fire :mode_change, :music_play, :music_stop, :sound_play,
    :network_msg_to, :config_manager

  constructor :resource_manager, :font_manager, :snelps_screen,
    :config_manager

  #TODO screen widths?
  def setup()
    base_setup
    @background = Surface.new(@snelps_screen.size)

    # TODO take this out
    @settings = {}
    @settings[:button_count] = 0

    @title_text = 
      @font_manager.render :excalibur, 70, "Snelps",true, LIGHT_GRAY

    @unscaled_warrior_image = 
      @resource_manager.load_image 'warrior_concept.png'
    @warrior_image = @unscaled_warrior_image.zoom([0.4,0.4],true)

    @layout = AbsoluteLayout.new self, @font_manager
    button = Button.new @layout, "Campaign" do |b|
      fire :mode_change, :campaign_play, "snelps"
    end

    @layout.add button, 250, 550

    # TODO how do I get the config_manager into the dialog?
    button = Button.new @layout, "Settings" do |b|
      settings = @config_manager.settings.dup
      modal_dialog SettingsDialog, settings do |d|
        @config_manager[:fullscreen] = d.settings[:fullscreen]
        @config_manager.save
      end
    end
    @layout.add button, 550, 550
  end

  def on_click(event)
    @layout.click(event)
  end

  def on_mouse_motion(event)
    @layout.mouse_motion(event)
  end

  def on_key_up(event)
    case event.key
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

  end

end
