# TODO move to gamebox
class ResourceManager
  def load_data_file(file_name)
    File.read(DATA_PATH + file_name)
  end
end

class UnitDefinition
  attr_writer :attributes
  def initialize(unit_builder, klass)
    @unit_builder = unit_builder
    @klass = klass
    @attributes = {}
  end

  def inherit_from(other_klass_sym)
    other_klass_def = @unit_builder.unit_definitions[other_klass_sym]
    raise "#{other_klass_sym} not yet defined" unless other_klass_def
    other_klass_def.attributes.each do |k, v|
      send k, v
    end
  end

  def behavior(behavior_def)
    @klass.instance_eval do
      has_behaviors behavior_def
    end
  end

  def attributes(attrs={})
    attrs.each do |k, v|
      send k, v
    end

    @attributes
  end

  def method_missing(method_name, default_value)
    @attributes[method_name] = default_value
    @klass.instance_eval do
      attr_writer method_name
      define_method method_name do
        val = instance_variable_get "@#{method_name}"
        val ? val : default_value
      end
    end
  end
end

class UnitClassBuilder
  construct_with :resource_manager
  attr_reader :unit_definitions

  def build(file_name)
    @unit_definitions = {}
    @unit_def_string = resource_manager.load_data_file(file_name)
    instance_eval @unit_def_string
  end

  def define_unit(unit_name, &blk)
    unit_klass_name = unit_name.to_s.classify
    unit_klass = Class.new Actor
    definition = UnitDefinition.new self, unit_klass
    @unit_definitions[unit_name] = definition
    definition.instance_eval &blk
    Object.const_set(unit_klass_name, unit_klass)
  end
end
