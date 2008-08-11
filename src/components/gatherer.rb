# can gather a resource of some kind
module Gatherer

  def self.included(target)
    target.add_setup_listener :setup_gatherer
    #target.can_fire :emtpy
  end

  def setup_gatherer(args)
    require_components :pathable
  end

end
