class BaseMode

  attr_accessor :modal_dialogs, :x, :y


  def base_setup()
    @x = 0 unless @x
    @y = 0 unless @y
    @modal_dialogs ||= []
  end

  def modal_dialog(klass, *args, &block)
    md = klass.new(self, *args)
    md.on_close = block if block_given?
    md.when :destroy_modal_dialog do |d|
      @modal_dialogs.pop
      if d.apply?
        d.close_callback
      end
    end
    @modal_dialogs << md
    end

  def fire_or_dispatch_to_modal(event_name, *args)
    target = @modal_dialogs.empty? ? self : @modal_dialogs.first
    target.send "on_#{event_name}", *args
  end

  # called by controller
  def handle_key_up(event)
    fire_or_dispatch_to_modal :key_up, event
  end

  def handle_click(event)
    fire_or_dispatch_to_modal :click, event
  end

  def handle_mouse_motion(event)
    fire_or_dispatch_to_modal :mouse_motion, event
  end

  def handle_mouse_dragging(*args)
    fire_or_dispatch_to_modal :mouse_dragging, *args
  end

  def handle_mouse_drag(*args)
    fire_or_dispatch_to_modal :mouse_drag, *args
  end

  def handle_network(event)
    fire_or_dispatch_to_modal :network, event
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
  def on_mouse_dragging(start_x,start_y,event); end
  def on_network(event); end
  def start(*args); end
  def stop(*args); end

  def update(time);end
  def draw(dest);end
end
