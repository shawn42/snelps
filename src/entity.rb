require 'publisher'

class Entity
  extend Publisher
  attr_accessor :server_id, :entity_type, :player_id

  can_fire :destroyed,:enabled,:disabled

  def initialize(server_id, *args)
    @server_id = server_id

    @player_id = args.first[:player_id]
    @entity_type = args.first[:entity_type]
    setup(*args)
  end

  def self.add_update_listener(meth)
    @update_listeners ||= []
    @update_listeners << meth
  end

  def update(time)
    update_listeners = self.class.instance_variable_get("@update_listeners")
    unless update_listeners.nil?
      update_listeners.each do |meth_callback|
        self.send(meth_callback, time)
      end
    end
  end

  def setup(*args)
    setup_listeners = self.class.instance_variable_get("@setup_listeners")
    unless setup_listeners.nil?
      setup_listeners.each do |meth_callback|
        self.send(meth_callback, *args)
      end
    end
  end

  def self.add_setup_listener(meth)
    @setup_listeners ||= [] 
    @setup_listeners << meth
  end

  def is?(behavior)
    components.include? behavior
  end

  # assertion check for component dependencies
  # TODO, this causes a strage error, should shutdown game?!
  def require_components(*behaviors)
    for behavior in behaviors
      raise "#{behavior} behavior required" unless is? behavior
    end
  end

  def enable()
    fire :enabled, self
  end

  def disable()
    fire :disabled, self
  end

  # get rid of an entity that isn't "alive"
  def destroy()
    fire :destroyed, self
  end


end
