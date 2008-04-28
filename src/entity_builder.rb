$: << "../lib"
require 'yaml'
require 'positionable'
require 'animated'
require 'movable'
require 'unit_component'
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
    for unit_type, unit_def in @gameplay_config
      components = unit_def[:components].collect{|c|Object.const_get(Inflector.camelize(c))}
      properties = unit_def.keys.dup
      properties.delete :components
      klass = Class.new(Entity){
        components.each do |c|
          include c
        end

        properties.each do |prop|
          attribute prop => unit_def[prop]
        end
      }
      klass_name = Inflector.camelize(unit_type)
      Object.const_set klass_name, klass
    end
  end
end

if $0 == __FILE__
  require '../config/environment'
  require 'resource_manager'
  rm = ResourceManager.new
  eb = EntityBuilder.new :resource_manager => rm
  e = Engineer.new 23
  p e.health
  p e.armor
end
