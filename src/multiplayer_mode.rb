require 'game_mode'
require 'map_selection_dialog'

class MultiplayerMode < GameMode
  
  def start(*args)
    @map = nil
    show_map_selector
    
    fire :music_play, :background_music

    #super
  end
  
  def handle_map_script_victory
    puts 'multi victory means wha?'
  end
  
  def show_map_selector
    dialog = MapSelectionDialog.new :modal => app, :x => 150, :y => 100,  :w=>380, :h=>370
    dialog.when :load do |map_name|
      start_next_map map_name
      self.show
    end
    dialog.when :cancel do
      fire :mode_change, :main_menu
    end

    dialog.display
  end
end
