
class Entity
  attr_accessor :server_id, :entity_type

  def initialize(server_id, *args)
    @server_id = server_id

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
end
