class MainStage < Stage
  def setup
    super
    # TODO conjectify
    UnitClassBuilder.new.build 'units/definitions.rb'

    @unit_manager = spawn :unit_manager

    @earth_worker = spawn :earth_worker, x: 120, y: 120
    @fire_worker = spawn :fire_worker, x: 220, y: 120
  end
end

