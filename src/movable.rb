module Movable 
#  attr_accessor :destination, :moving, :direction

  def self.included(target)
    # TODO finish this
#    target.add_setup_listener do |*args|
#      setup_movable *args
#    end
    target.add_update_listener :update_movable 
    target.add_setup_listener :setup_movable 
  end

  def setup_movable(*args)
    @base_speed = self.speed / 1000.0
  end

  def update_movable(time)
#    p "updating movable"
  end
end
