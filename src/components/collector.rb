module Collector
  def self.included(target)
#    target.add_setup_listener :setup_movable 
#    target.can_fire :move
  end

  def deposit(amount)
    # TODO add these to the players stuff
    puts "#{amount} deposited"
  end
end
