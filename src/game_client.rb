class GameClient
  STEP_SIZE = 20.0

  attr_accessor :viewport
  constructor :mode_container, :snelps_screen, :input_manager

  def setup()
    factory = Rubygoo::AdapterFactory.new
    @render_adapter = factory.renderer_for :rubygame, @snelps_screen.screen
    @gui = Rubygoo::App.new :renderer => @render_adapter, :theme => 'snelps', 
      :data_dir => "#{File.dirname(__FILE__)}/gui/themes", :mouse_cursor => false

    @gui.add @mode_container
    @app_adapter = factory.app_for :rubygame, @gui

    @input_manager.when :event_received do |evt|
      @app_adapter.on_event evt
    end
    @snelps_screen.show_cursor = false
  end

  def update(time)
    steps = (time / STEP_SIZE).ceil
    steps.times do 
      @gui.update STEP_SIZE
    end

    @gui.draw @render_adapter
  end

end
