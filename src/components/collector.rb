module Collector
  def self.included(target)
    target.add_setup_listener :setup_collector
#    target.can_fire :move
  end

  def setup_collector(args)
    @entity_manager = args[:entity_manager]
  end

  def deposit(amount)
    # TODO should fire some event?
    player = @entity_manager.players.find{|p|p.local == true}
    player.vim += amount 
#    puts "#{amount} deposited, #{player.vim} total"
  end
end
