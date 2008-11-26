# this behavior is for auto-morphing entities that represent a group ability of
# some sort
module Automorphable

  def self.included(target)
    target.add_update_listener :update_automorphable
    target.add_setup_listener :setup_automorphable
  end

  def setup_automorphable(*args)
    @ttl = self.ttl

    # this will go into the melee_attackable
    self.animation_image_set = :attacking
    self.animate
  end

  def update_automorphable(time)
    unmorph unless @ttl > 0

    @ttl -= time
  end

  def automorph(composing_ents)
    @ents = composing_ents
    consume_ents @ents
  end

  def consume_ents(ents)
    @ents = ents
    for ent in @ents
      ent.disable
    end
  end

  def release_ents()
    for ent in @ents
      ent.enable
    end
  end

  def unmorph()
    # kill self?
    puts "automorph finished"
    release_ents
    self.destroy
  end

end
