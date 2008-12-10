# shows the player what abilities are available, based on the currently
# selected entities.
require 'rubygoo'
class AbilitiesPanel < Rubygoo::Container

  can_fire :ability_selected

  def initialize(opts)
    super opts
    @abilities = []
  end
  
  def update_abilities(abilities)
    @abilities = abilities
    clear
    build_gui
  end

  def build_gui()
    starting_y = @y

    @abilities.size.times do |i|
      ability = @abilities[i]
      ability_button = Rubygoo::Button.new ability.to_s, :x=>@x,:y=>starting_y,:w=>@w
      ability_button.when :pressed do
        fire :ability_selected, ability
      end
      add ability_button

      starting_y += ability_button.h
    end
  end
end
