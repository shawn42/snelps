module Audible 
  def self.included(target)
    target.add_setup_listener :setup_audible
  end

  def setup_audible(args)
    @sound_manager = args[:sound_manager]
  end

  def death_sound()
    @sound_manager.play_sound :ent_death
  end

end
