class Module
  def attribute(name, &block)
    return name.map {|k,v| attribute(k) {v}} if name.is_a?(Hash)
    # also add it as a class method
    # Tree.default_z
    self.class.send :define_method, "default_#{name}", block || proc{nil}
    define_method("__#{name}__", block || proc{nil})
    class_eval <<-ZEN
    attr_writer :#{name}
    def #{name}
    defined?(@#{name}) ? @#{name} : @#{name} = __#{name}__
    end
    def #{name}?
    true unless #{name}.nil?
    end
    ZEN
  end
end

