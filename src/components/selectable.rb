# Selectable module allows for an object to be selected.
module Selectable

  attr_accessor :selected
  def self.included(target)
#    target.add_setup_listener :setup_selectable 
  end

#  def setup_selectable(args)
#    @base_speed = self.speed / 1000.0
#  end

  def select()
    @selected = true
  end

  def deselect()
    @selected = false
  end

  def selected?()
    @selected
  end

end
