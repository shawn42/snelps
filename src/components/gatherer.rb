require 'ostruct'

# can gather a resource of some kind
module Gatherer
  # TODO does this need to be based off of map tile size?
  DEFAULT_GATHERER_RANGE = 16

  def self.included(target)
    target.add_setup_listener :setup_gatherer
    target.add_update_listener :update_gatherer
    #target.can_fire :emtpy
  end

  def setup_gatherer(args)
    require_components :able, :pathable, :rangable
    add_ability :gather

    @gathering_range = self.gathering_range if self.respond_to? :gathering_range
    @gathering_range ||= DEFAULT_GATHERER_RANGE
  end

  def gather_targets?(args)
    target = args[:target]
    target.respond_to? :is? and target.is? :providable
  end

  def update_gatherer(time)
    if @full
      if @base
        if within_range? @base, @gathering_range
          do_dump
        end
        # return to base
        # TODO, I think this will create a new path every cycle
        path_to @base.tile_x, @base.tile_y, [@base] if @path.nil?
      end
    else
      unless @current_gatherer_target.nil?
        if within_range? @current_gatherer_target, @gathering_range
          if @current_gatherer_target.empty?
            set_gathering_target nil
          else
            do_gather
          end
        else
          path_to @current_gatherer_target.tile_x, @current_gatherer_target.tile_y, [@current_gatherer_target]
        end
      end
    end
  end

  def gather(args)
    target = args[:target]

    if target.is_a? Array
      gather_location args
    else
      gather_entity args
    end
  end

  def gather_location(args)
    # TODO, look for resources?
    target = args[:target]
    path_to target[0].to_i, target[1].to_i
  end

  def gather_entity(args)
    target = args[:target]
    if target.is? :providable
      set_gathering_target target
    end
  end

  def do_gather()
    @current_gatherer_target.take self.carrying_capacity
    @full = true
    drop_off
  end

  def drop_off()
    # TODO find closest using Pathfinder.diagonal_heuristic
    # TODO how should I change the Pathfinder to take non-nodes?
    @base = @entity_manager.base_entities.values.sort_by{|b| Pathfinder.diagonal_heuristic( OpenStruct.new(:x=>@tile_x,:y=>@tile_y), OpenStruct.new(:x=>b.tile_x,:y=>b.tile_y))}.first
  end

  def do_dump()
    @base.deposit self.carrying_capacity
    @full = false
    # TODO add resource to player's total
  end

  def within_gathering_range?(target = @current_gatherer_target)
      from = Node.new tile_x, tile_y
      to = Node.new target.tile_x, target.tile_y
      dist = Pathfinder.diagonal_heuristic from, to

      dist <= @gathering_range
  end

  def set_gathering_target(target)
    @current_gatherer_target = target
  end
end
