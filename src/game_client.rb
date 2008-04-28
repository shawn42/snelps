class GameClient

  attr_accessor :viewport, :state
  constructor :mode_controller

  def setup()
  end

  def update(time)
    @mode_controller.update time
  end

end
