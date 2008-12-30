require 'rubygoo'
require 'publisher'
require 'settings_dialog'

class MainMenuMode < Rubygoo::Container 
  extend Publisher

  can_fire :mode_change, :music_play, :music_stop, :sound_play,
    :network_msg_to, :config_manager

  def initialize(opts)
    opts[:visible] = false
    opts[:enabled] = false
    opts[:id] = :main_menu
    super opts

    @resource_manager = opts[:resource_manager]
    @config_manager = opts[:config_manager]

    build_gui
  end

  def build_gui()
    bg_image = 
      @resource_manager.load_image 'menu/menu_image.png'
    bg = Rubygoo::Icon.new :x=>-2,:y=>0,:icon=>bg_image
    add bg
    
    banner_image = 
      @resource_manager.load_image 'menu/buttons_bg.png'
    banner = Rubygoo::Icon.new :x=>400,:y=>450,:icon=>banner_image
    add banner

    campaign_off_img = 
      @resource_manager.load_image 'menu/cpaign_btn_off.png'
    campaign_on_img = 
      @resource_manager.load_image 'menu/cpaign_btn_on.png'
    button = Rubygoo::Button.new "Campaign", :x=>416,:y=>522, :x_pad=>0,:y_pad=>0, :image=>campaign_off_img, :hover_image=>campaign_on_img
    button.when :pressed do |b|
      fire :mode_change, :campaign_play, "snelps"
    end
    add button

    multi_off_img = 
      @resource_manager.load_image 'menu/multip_btn_off.png'
    multi_on_img = 
      @resource_manager.load_image 'menu/multip_btn_on.png'
    button = Rubygoo::Button.new "Multiplayer", :x=>416,:y=>563, :x_pad=>0,:y_pad=>0, :image=>multi_off_img, :hover_image=>multi_on_img
    button.when :pressed do |b|
      fire :mode_change, :multi_play, "snelps"
    end
    add button

    settings_off_img = 
      @resource_manager.load_image 'menu/settings_btn_off.png'
    settings_on_img = 
      @resource_manager.load_image 'menu/settings_btn_on.png'
    button = Rubygoo::Button.new "Settings",:x=>416,:y=>604, :x_pad=>0,:y_pad=>0,:image=>settings_off_img,:hover_image=>settings_on_img
    button.when :pressed do |b|
      settings = @config_manager.settings.dup

      settings_dialog = SettingsDialog.new :modal => app, :x=>150, :y=>100, :w=>380, :h=>370, :settings => settings
      settings_dialog.when :save do |d|
        @config_manager[:fullscreen] = d.settings[:fullscreen]
        @config_manager[:sound] = d.settings[:sound]
        @config_manager.save
      end
      settings_dialog.display
    end
    add button

    quit_off_img = 
      @resource_manager.load_image 'menu/quit_btn_off.png'
    quit_on_img = 
      @resource_manager.load_image 'menu/quit_btn_on.png'
    button = Rubygoo::Button.new "Quit",:x=>416,:y=>645, :x_pad=>0,:y_pad=>0,:image=>quit_off_img,:hover_image=>quit_on_img
    button.when :pressed do |b|
      throw :rubygame_quit
    end
    add button

    add Rubygoo::Label.new("Snelps version #{SNELPS_VERSION}", :x=>910,:y=>780,:font_size=>8)

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
