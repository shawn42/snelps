class HookedGosuWindow
  def needs_cursor?;true;end
end

class UnitManagerView < ActorView
  def draw(target, x_off, y_off, z)
    if actor.dragging
      to = actor.to
      from = actor.from
      target.draw_box from[0], from[1], to[0], to[1], [255,0,0], 99_999
    end
  end
end

class UnitManager < Actor
  attr_accessor :dragging, :from, :to
  def setup
    input_manager.reg :mouse_down do |evt|
      @mouse_down = true
      @from = evt[:data]
    end

    input_manager.reg :mouse_motion do |evt|
      @dragging = true if @mouse_down
      @to = evt[:data]
    end

    input_manager.reg :mouse_up do |evt|
      @mouse_down = false
      @dragging = false
    end

  end
end
