class FireWorker < Unit
  has_behaviors :animated

  DIRECTIONS = %w(n ne e se s sw w nw)
  def setup
    @dir = -1
    input_manager.reg :keyboard_down, KbSpace do
      next_direction
    end
  end

  def next_direction
    @dir = (@dir + 1) % DIRECTIONS.size
    self.action = "walk_#{DIRECTIONS[@dir]}"
  end

end
