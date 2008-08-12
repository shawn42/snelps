module Rangable
  def self.included(target)
#    target.add_setup_listener :setup_movable 
#    target.can_fire :move
  end

  def within_range?(target, range)
      from = Node.new tile_x, tile_y
      to = Node.new target.tile_x, target.tile_y
      dist = Pathfinder.diagonal_heuristic from, to

      dist <= range
  end
end
