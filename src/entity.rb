
class Entity
  include Sprites::Sprite

  attr_accessor :server_id, :entity_type

  def initialize(server_id, *args)
    @server_id = server_id

    @entity_type = args.first[:entity_type]
    setup(*args)
  end

  def self.add_update_listener(meth)
#    p "#{self.methods.sort.inspect}"
#    p "#{self} #{meth}"
    @@update_listeners ||= []
    @@update_listeners << meth
  end

  def update(time)
    @@update_listeners.each do |meth_callback|
      self.send(meth_callback, time)
    end
  end

  def setup(*args)
    @@setup_listeners.each do |meth_callback|
      self.send(meth_callback, *args)
    end
  end

  def self.add_setup_listener(meth)
    @@setup_listeners ||= [] 
    @@setup_listeners << meth
  end
end
