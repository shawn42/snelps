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

  def initialize(opts)
    @resource_manager = opts[:resource_manager]
    @font_manager = opts[:font_manager]
    @snelps_screen = opts[:snelps_screen]
    @config_manager = opts[:config_manager]

    opts[:w] = @snelps_screen.size[0]
    opts[:h] = @snelps_screen.size[1]
    super opts

    build_gui
  end

  def build_gui()
    title = Rubygoo::Label.new "Snelps", :x=>360,:y=>10,:font_size=>70
    add title

    @warrior_image = 
      @resource_manager.load_image 'warrior_concept_medium.png'
    warrior = Rubygoo::Icon.new :x=>300,:y=>90,:icon=>@warrior_image
    add warrior

    button = Rubygoo::Button.new "Campaign", :x=>150,:y=>550 
    button.when :pressed do |b|
      fire :mode_change, :campaign_play, "snelps"
    end
    add button

    button = Rubygoo::Button.new "Quit",:x=>712,:y=>550 
    button.when :pressed do |b|
      throw :rubygame_quit
    end
    add button

    button = Rubygoo::Button.new "Settings",:x=>450,:y=>550
    button.when :pressed do |b|
      settings = @config_manager.settings.dup

      # TODO finish RUBYGOO
      settings_dialog = SettingsDialog.new :modal => app, :x=>100, :y=>100, :w=>824, :h=>600, :settings => settings
      settings_dialog.when :save do |d|
        @config_manager[:fullscreen] = d.settings[:fullscreen]
        @config_manager[:sound] = d.settings[:sound]
        @config_manager.save
      end
      settings_dialog.show
    end
    add button
  end

  def key_released(event)
    throw :rubygame_quit if event.data[:key] == K_ESCAPE
  end

  def start(*args)
    fire :music_play, :menu_music
    self.show
  end

  def stop(*args)
    fire :music_stop, :menu_music
    self.hide
  end

  def focussed?()
    true
  end

end
