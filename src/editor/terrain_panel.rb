# shows the player what abilities are available, based on the currently
# selected entities.
require 'rubygoo'
class TerrainPanel < Rubygoo::Container
  attr_accessor :map, :group

  can_fire :tile_selected, :tile_group_selected

  def initialize(opts)
    super opts
  end

#    --- 
#    :grass: 
#      :prefix: grass-
#      :suffix: .png
#      :first: 1
#      :last: 16
#    :water: 
#      :prefix: water-
#      :suffix: .png
#      :first: 17
#      :last: 32

  def build_gui()
    starting_y = @y
    starting_x = @x

    tile_config = @map.tile_config
    tile_width = @map.tile_size
    group_pad = 10
    sub_pad = 5

    @terrain_sub_panels = {}

    tile_config.keys.size.times do |i|
      type = tile_config.keys[i]
      config = tile_config[type]

      range_array = (config[:first]..config[:last]).to_a
      tile_id = range_array.first
      icon = @map.resource_manager.load_image File.join("terrain","#{config[:prefix]}#{tile_id}#{config[:suffix]}")

      #only make a button for non-transition groups
      unless config[:transition]
        type_button = Rubygoo::Button.new " ",:x=>starting_x,:y=>starting_y,:image=>icon,:w=>tile_width,:h=>tile_width
        type_button.when :pressed do |event|
          fire :tile_group_selected, type
  #        change_group type
        end
        add type_button
        starting_x += tile_width + group_pad
      end


      starting_sub_x = @x
      starting_sub_y = @y+2*tile_width
      sub_x = starting_sub_x
      sub_y = starting_sub_y

      type_sub_panel = Rubygoo::Container.new :x=>@x,:y=>sub_y,:w=>@w,:h=>@h,:visible=>false,:enabled=>false

      ids = range_array.dup
      range_array.size.times do |i|
        tid = range_array[i]

        icon = @map.resource_manager.load_image File.join("terrain","#{config[:prefix]}#{tid}#{config[:suffix]}")
        if icon
          terrain_button = Rubygoo::Button.new " ",:x=>sub_x,:y=>sub_y,:image=>icon,:w=>tile_width,:h=>tile_width

          terrain_button.when :pressed do |event|
            fire :tile_selected, tid
          end
          type_sub_panel.add terrain_button

          if sub_x > (starting_sub_x + 110)
            sub_x = starting_sub_x 
            sub_y += tile_width + sub_pad
          else
            sub_x += tile_width + sub_pad
          end
        end

      end

      @terrain_sub_panels[type] = type_sub_panel

      add type_sub_panel

    end

    def change_group(type)
      puts "change called"
      @terrain_sub_panels[@group].hide if @group and @terrain_sub_panels[@group]
      @group = type
      @terrain_sub_panels[@group].show if @terrain_sub_panels[@group]
    end

  end
end
