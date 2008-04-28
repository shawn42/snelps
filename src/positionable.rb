module Positionable
  attr_accessor :x, :y

  def self.included(target)
    target.add_update_listener do |time|
      update_positionable time
    end
  end

  def update_positionable(time)
    p "updating positionable"
  end

end
