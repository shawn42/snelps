require 'rubygoo'
require 'publisher'
class IntroMode < Rubygoo::Container 
  extend Publisher

  can_fire :mode_change, :music_play, :music_stop, :sound_play,
    :network_msg_to, :config_manager

  def initialize(opts)
    @resource_manager = opts[:resource_manager]
    @snelps_screen = opts[:snelps_screen]
    @config_manager = opts[:config_manager]

    opts[:w] = @snelps_screen.size[0]
    opts[:h] = @snelps_screen.size[1]
    super opts

    build_gui
  end

  def build_gui()
    title = Rubygoo::Label.new "Snelps Intro", :x=>360,:y=>10,:font_size=>70
    add title

    @warrior_image = 
      @resource_manager.load_image 'warrior_concept_medium.png'
    warrior = Rubygoo::Icon.new :x=>300,:y=>90,:icon=>@warrior_image
    add warrior
  end

  def key_released(event)
    fire :mode_change, :main_menu
  end

  def mouse_up(event)
    fire :mode_change, :main_menu
  end

  def start(*args)
    fire :music_play, :intro_music
    self.show

    # TODO add kens burns effect to large images
  end

  def stop(*args)
    fire :music_stop, :intro_music
    self.hide
  end

  def focussed?()
    true
  end

end
