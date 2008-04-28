class BaseMode

  attr_accessor :modal_dialogs, :x, :y
  
  def base_setup()
    @x = 0 unless @x
    @y = 0 unless @y
  end

  def modal_dialog(klass, *args, &block)
    @modal_dialogs ||= []
    md = klass.new(self, *args)
    md.on_close = block if block_given?
    md.when :destroy_modal_dialog do |d|
      if d.apply?
        d.close_callback
      end
      @modal_dialogs.pop
    end
    @modal_dialogs << md
  end
  
  # called by controller
  def handle_key_up(event)
    @modal_dialogs ||= []
    if @modal_dialogs.empty?
      on_key_up event
    else
      @modal_dialogs.first.on_key_up event
    end
  end

  def handle_click(event)
    @modal_dialogs ||= []
    if @modal_dialogs.empty?
      on_click event
    else
      @modal_dialogs.first.on_click event
    end
  end

  def handle_mouse_motion(event)
    @modal_dialogs ||= []
    if @modal_dialogs.empty?
      on_mouse_motion event
    else
      @modal_dialogs.first.on_mouse_motion event
    end
  end

  def handle_mouse_drag(start_x, start_y, event)
    @modal_dialogs ||= []
    if @modal_dialogs.empty?
      on_mouse_drag start_x, start_y, event
    else
      @modal_dialogs.first.on_mouse_drag start_x, start_y, event
    end
  end

  def handle_network(event)
    @modal_dialogs ||= []
    if @modal_dialogs.empty?
      on_network event
    else
      @modal_dialogs.first.on_network event
    end
  end
     
  def handle_draw(dest)
    @modal_dialogs ||= []
    draw(dest)
    unless @modal_dialogs.empty?
      @modal_dialogs.each do |md|
        md.draw dest
      end
    end
  end

  # implement these in subclases
  def on_key_up(event); end
  def on_click(event); end
  def on_mouse_motion(event); end
  def on_mouse_drag(start_x,start_y,event); end
  def on_network(event); end
  def start(*args); end
  def stop(*args); end

  def update(time);end
  def draw(dest);end
end
