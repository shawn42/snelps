require 'yaml'
# represents a game map
# original map idea is to load/save as yaml
class Map
  attr_accessor :tile_size
  def initialize(args = {})
    @width = args[:width].nil? ? 6 : args[:width]
    @height = args[:height].nil? ? 6 : args[:height]
    # nubmer of pixels of each tile
    @tile_size = args[:tile_size].nil? ? 32 : args[:width]
    @tiles = args[:tiles].nil? ? Array.new(@width, Array.new(@height)) : args[:tiles]
    load_images
  end
  def load_images()
    @tile_images = Array.new(@width, Array.new(@height))
    if @tiles[0][0].is_a? Fixnum
      @tiles.each_with_index do |row,i|
        row.each_with_index do |col,j|
          img = Surface.load_image(GFX_PATH + "terrain#{col}.png")
          @tile_images[i][j] = img
        end
      end
    else
      # assume image names
    end
  end

  def load(map_name)
  end

  def save(file_name)
  end

  def at(x,y)
    @tiles[x][y]
  end
  def set(x,y,val)
    @tiles[x][y] = val
  end

  def draw(destination)
    count = 0
    @tile_images.each_with_index do |row,i|
      row.each_with_index do |col,j|
        count += 1
        x = i * @tile_size
        y = j * @tile_size
        col.blit destination, [x,y,@tile_size,@tile_size]
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
  tiles = []
  num_rows.times do |i|
    tiles[i] = []
    num_cols.times do |j|
      tiles[i][j] = rand 271
    end
  end
  
  map = Map.new :tiles => tiles, :width => tiles.size, :height => tiles.first.size
  screen = Screen.set_mode([num_cols * map.tile_size,num_rows * map.tile_size])
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
