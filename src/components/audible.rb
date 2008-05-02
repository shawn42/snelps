module Audible 
  attr_accessor :dest

  def self.included(target)
    target.add_setup_listener :setup_audible
  end

  def setup_audible(args)

    @sound_manager = args[:sound_manager]

  end

end
