
class Entity
  # this is included here because it has its own initialize and it will
  # override ours
  include Sprites::Sprite
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
    self.class.instance_variable_get("@update_listeners").each do |meth_callback|
      self.send(meth_callback, time)
    end
  end

  def setup(*args)
    self.class.instance_variable_get("@setup_listeners").each do |meth_callback|
      self.send(meth_callback, *args)
    end
  end

  def self.add_setup_listener(meth)
    @setup_listeners ||= [] 
    @setup_listeners << meth
  end
end
