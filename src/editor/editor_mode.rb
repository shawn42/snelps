require 'rubygoo'
require 'publisher'
require 'player'
require 'map'
require 'mini_map'
require 'editor_view'
require 'terrain_panel'
require 'mini_map_view'
require 'map_selection_dialog'

class EditorMode < Rubygoo::Container
  extend Publisher
  include Commands

  attr_accessor :editor_mouse_view
  can_fire :mode_change, :music_play, :music_stop, :sound_play

  def initialize(opts)
    @resource_manager = opts[:resource_manager]
    @config_manager = opts[:config_manager]
    @entity_manager = opts[:entity_manager]
    @map_editor = opts[:map_editor]
    @viewport = opts[:viewport]
    @editor_mouse_view = opts[:editmouse_view]
    @entity_builder = opts[:entity_builder]

    opts[:visible] = false
    opts[:enabled] = false
    super opts

    setup
    build_gui
  end

  def build_gui()

    # ACTUAL GAMEPLAY
    @editor_view = EditorView.new(:x=>10,:y=>30, :visible=>false)
    add @editor_view

    @terrain_panel = TerrainPanel.new :x=>835,:y=>350,:w=>180,:h=>300
    @terrain_panel.when :tile_group_selected do |tg|
      if @map_editor.multi_select
        tg = [tg.to_s,@terrain_panel.group.to_s].sort.join('_').to_sym
      end
      @terrain_panel.change_group tg
    end

    @terrain_panel.when :tile_selected do |tile_id|
      @map_editor.current_tile_stamp = tile_id
      @editor_mouse_view.cursor = @map.tile_image_for tile_id
    end

    add @terrain_panel


    # GUI LABELS
    add Rubygoo::Label.new("Snelps", :x=>60)
    add Rubygoo::Label.new("5/20", :x=>630, :y=>20, :font_size=>10)
    add Rubygoo::Label.new("Vim 200", :x=>680, :y=>20, :font_size=>10)
    add Rubygoo::Label.new("Daub 200", :x=>730, :y=>20, :font_size=>10)

    # MINIMAP
    @mini_map_view = MiniMapView.new :x=>850, :y=>150, :visible=>false
    add @mini_map_view

    @unscaled_warrior_image = 
      @resource_manager.load_image 'warrior_concept.png'
    @warrior_image = @unscaled_warrior_image.zoom([0.2,0.2],true).flip(true,false)
    add Rubygoo::Icon.new(:icon=>@warrior_image,:x=>800)


    scroll_w = Viewport::ACTIVE_EDGE_WIDTH
    # scrolling hotspots
    scroll_right = Rubygoo::Widget.new :x=>989,:y=>0,
      :w=>scroll_w,:h=>800
    # TODO update publisher to allow easier hooking of many events to one callback
    scroll_right.when :mouse_exit do |evt|
      @viewport.vx = 0
    end
    scroll_right.when :mouse_motion do |evt|
      if scroll_right.mouse_over?
        @viewport.vx += Viewport::SCROLL_SPEED
      end
    end
    scroll_left = Rubygoo::Widget.new :x=>0,:y=>0,
      :w=>scroll_w,:h=>800
    scroll_left.when :mouse_exit do |evt|
      @viewport.vx = 0
    end
    scroll_left.when :mouse_motion do |evt|
      if scroll_left.mouse_over?
        @viewport.vx -= Viewport::SCROLL_SPEED
      end
    end
    scroll_up = Rubygoo::Widget.new :x=>0,:y=>0,
      :w=>1024,:h=>scroll_w
    scroll_up.when :mouse_exit do |evt|
      @viewport.vy = 0
    end
    scroll_up.when :mouse_motion do |evt|
      if scroll_up.mouse_over?
        @viewport.vy -= Viewport::SCROLL_SPEED
      end
    end
    scroll_down = Rubygoo::Widget.new :x=>0,:y=>765,
      :w=>1024,:h=>scroll_w
    scroll_down.when :mouse_exit do |evt|
      @viewport.vy = 0
    end
    scroll_down.when :mouse_motion do |evt|
      if scroll_down.mouse_over?
        @viewport.vy += Viewport::SCROLL_SPEED
      end
    end


    add scroll_right, scroll_left, scroll_up, scroll_down
  end

  def update(time)
    @viewport.update time if @viewport
  end

  def key_pressed(event)
    @map_editor.handle_key_down event
  end

  def key_released(event)
    case event.data[:key]
    when K_LEFT
      @viewport.jump :left
    when K_RIGHT
      @viewport.jump :right
    when K_UP
      @viewport.jump :up
    when K_DOWN
      @viewport.jump :down
    when K_ESCAPE
      throw :rubygame_quit
    else
#      @entity_manager.handle_key_up event
      @map_editor.handle_key_up event
    end
  end

  def setup()
    @players ||= []
  end
  
  def start(*args)
    @map = nil
    show_map_selector
    
    fire :music_play, :background_music
  end
  
  def stop(*args)
    fire :music_stop, :background_music
    self.hide
  end
  
  def show_map_selector
    dialog = MapSelectionDialog.new :modal => self.app, :x => 150, :y => 100,  :w=>380, :h=>370
    dialog.when :load do |map_name|
      start_next_map map_name
      self.show
    end
    dialog.when :cancel do
      throw :rubygame_quit
    end

    dialog.display
  end

  def start_next_map(map)
    
    @map = Map.load_from_file @resource_manager, map

    @terrain_panel.map = @map
    @terrain_panel.build_gui
    
    @viewport.setup
    @viewport.set_map_size(@map.pixel_width, @map.pixel_height)
    @map.viewport = @viewport

    @mini_map = MiniMap.new @map, @viewport, @entity_manager
    @mini_map.when :center_viewport do |x,y|
      @viewport.center_to x, y
    end

    @map.script.when :create_entity do |player,ent_type,tile_x,tile_y|
      # TODO, is there a better way of getting the z here?
      klass = Object.const_get Inflector.camelize(ent_type)
      z = klass.default_z
    end if @map.script

    # GUI STUFF
    @editor_view.map = @map
    @map_editor.map = @map
    @editor_view.viewport = @viewport
    @editor_view.map_editor = @map_editor

    @mini_map_view.mini_map = @mini_map

    @editor_view.show
    @mini_map_view.show
  end

  def focussed?()
    true
  end
end
