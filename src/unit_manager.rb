require 'unit'

class UnitManager
  def initialize(viewport, animation_manager, sound_manager, game_server)
    @viewport = viewport
    @game_server= game_server
    @animation_manager = animation_manager
    @sound_manager = sound_manager
    @units = []
  end
  def create_unit(unit_type, x, y)
    new_unit_id = @game_server.create_unit(unit_type, x, y)
    new_unit = Unit.new(
      :animation_manager => @animation_manager,
      :sound_manager => @sound_manager,
      :viewport => @viewport,
      :unit_type => unit_type,
      :x => x,
      :y => y
      )
    @units << new_unit
    new_unit
  end

  def draw(destination)
    @units.each do |u|
      u.draw destination
    end
  end
end
