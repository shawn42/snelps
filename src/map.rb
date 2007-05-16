require 'yaml'
require 'narray'
# represents a game map
# original map idea is to load/save as yaml
class Map
  def to_yaml_properties()
    ['@width', '@height', '@tile_size', '@converted_tiles']
  end
  attr_accessor :tile_size, :height, :width, :tile_images, :tiles, :converted_tiles, :viewport, :resource_manager
  def setup(args = {})
    @resource_manager = args[:resource_manager]
    @width = args[:width].nil? ? 6 : args[:width]
    @height = args[:height].nil? ? 6 : args[:height]

    # nubmer of pixels of each tile
    @tile_size = args[:tile_size].nil? ? 32 : args[:width]
    @tiles = args[:tiles].nil? ? NArray.object(@width, @height) : args[:tiles]
    load_images
  end
  def load_images()
    @tile_images = NArray.object @width, @height
    if @tiles[0,0].is_a? Fixnum
      @width.times do |i|
        @height.times do |j|
          # TODO use resource manager
          @tile_images[i,j] = 
            @resource_manager.load_image "terrain#{@tiles[i,j]}.png"
        end
      end
    else
      # assume image names
    end
  end

  def pixel_height()
    @height * @tile_size
  end

  def pixel_width()
    @width * @tile_size
  end

  def self.load_from_file(resource_manager, map_name)
    map = resource_manager.load_map(map_name)
    map.resource_manager = resource_manager
    map.tiles = NArray.object(map.width, map.height)
    map.converted_tiles.each_with_index do |row,i|
      row.each_with_index do |col,j|
        map.tiles[i,j] = col
      end
    end
    map.load_images
    map
  end

  def save(file_name)
    @converted_tiles = @tiles.to_a
    @resource_manager.save_map self, file_name
  end

  def at(x,y)
    @tiles[x,y]
  end

  def set(x,y,val)
    @tiles[x,y] = val
  end

  def draw(destination)
#    @tile_images.each_with_index do |row,i|
#      row.each_with_index do |col,j|
    @width.times do |i|
      @height.times do |j|
        x = i * @tile_size
        y = j * @tile_size
        @tile_images[i,j].blit destination, @viewport.world_to_view(x,y)
      end
    end
  end
end

if $0 == __FILE__

  $: << "#{File.dirname(__FILE__)}/../config"
  $: << "#{File.dirname(__FILE__)}"
  require "environment"
  require "rubygame"
  include Rubygame

  $stdout.sync = true
  Rubygame.init()

  queue = EventQueue.new() # new EventQueue with autofetch
  queue.ignore = [ActiveEvent]
  clock = Clock.new()
  clock.target_framerate = 40

  num_rows = 20
  num_cols = 20
  tiles = NArray.int(num_rows,num_cols)
  num_rows.times do |i|
    num_cols.times do |j|
      tiles[i,j] = rand 271
    end
  end
  
#  map = Map.new 
#  map.setup :tiles => tiles, :width => num_rows, :height => num_cols
  map = Map.load_from_file "random_map.yml"
#  map.save "random_map.yml"
  screen = Screen.set_mode([map.width * map.tile_size,map.height * map.tile_size])
  screen.title = "Map Test"
  background = Surface.new(screen.size)

  update_time = 0
  fps = 0
  catch(:rubygame_quit) do
    loop do
      queue.each do |event|
        case event
        when KeyDownEvent
          case event.key
          when K_ESCAPE
            throw :rubygame_quit 
          when K_Q
            throw :rubygame_quit 
          end
        when QuitEvent
          throw :rubygame_quit
        end
      end

      background.blit(screen,[0,0])
      map.draw(screen)
      screen.update()
      update_time = clock.tick()
      unless fps == clock.framerate
        fps = clock.framerate
        screen.title = "Snelps [%d fps]"%fps
      end
    end
  end
  Rubygame.quit()
end
