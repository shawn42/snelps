$: << "../lib"
require 'yaml'
require 'entity'
require 'inflector'
require 'constructor'
require 'attribute'

class EntityBuilder
  constructor :resource_manager
  
  def setup()
    @gameplay_config = @resource_manager.load_entity_config "units"
    build_dynamic_classes
  end

  def build_dynamic_classes
    for entity_type, unit_def in @gameplay_config
      components = unit_def[:components].collect{|c|require c.to_s;Object.const_get(Inflector.camelize(c))}
      properties = unit_def.keys.dup
      properties.delete :components
      klass = Class.new(Entity){
        components.each do |c|
#          if c.to_s == "Wanderer"
#            p self
#          end
          include c
        end

        properties.each do |prop|
          attribute prop => unit_def[prop]
        end
      }
      klass_name = Inflector.camelize(entity_type)
      Object.const_set klass_name, klass
    end
  end
end
