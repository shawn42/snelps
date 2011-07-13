class MainStage < Stage
  def setup
    super

    @unit_manager = spawn :unit_manager

    @earth_worker = spawn :earth_worker, :x => 120, :y => 120
    @fire_worker = spawn :fire_worker, :x => 220, :y => 120
  end
end

