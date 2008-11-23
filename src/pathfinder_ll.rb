Node = Struct.new :x,:y,:z,:dir,:cost,:h,:parent

class Pathfinder
  # ratio of about 1:square root of 2 (for the sake of whole #'s)
  TRAVEL_COST_STRAIGHT = 10
  TRAVEL_COST_DIAG = 14

  def initialize(entity_manager, width, height)
    @width = width
    @height = height
    @entity_manager = entity_manager
  end

  def self.diagonal_heuristic(c,t)
    h_diagonal = [(c.x-t.x).abs, (c.y-t.y).abs].min
    h_straight = ((c.x-t.x).abs + (c.y-t.y).abs)
    return TRAVEL_COST_DIAG * h_diagonal + TRAVEL_COST_STRAIGHT * (h_straight - 2*h_diagonal)
  end

  #return a array of adjacent nodes without testing validity
  def adjacent_nodes(n)
    x = n.x
    y = n.y
    z = n.z
    nodes = [ 
      Node.new(x-1, y-1, z, :nw, TRAVEL_COST_DIAG,nil,nil),
      Node.new(x-1, y+1, z, :sw, TRAVEL_COST_DIAG,nil,nil),
      Node.new(x+1, y-1, z, :ne, TRAVEL_COST_DIAG,nil,nil),
      Node.new(x+1, y+1, z, :se, TRAVEL_COST_DIAG ,nil,nil),
      Node.new(x-1, y, z, :w, TRAVEL_COST_STRAIGHT,nil,nil),
      Node.new(x+1, y, z, :e, TRAVEL_COST_STRAIGHT,nil,nil),
      Node.new(x, y-1, z, :n, TRAVEL_COST_STRAIGHT,nil,nil),
      Node.new(x, y+1, z, :s, TRAVEL_COST_STRAIGHT,nil,nil)
    ]

    nodes
  end

  # test if the node is valid (contains no obstacles, and is in the map)
  def is_valid?(n,ignore_objects)
    x = n.x
    y = n.y
    z = n.z
    return false if(x<0 or y<0 or x>=@width or y>=@height)
    return false if @entity_manager.has_obstacle?(x,y,z,ignore_objects)
    return true
  end

  # return the best path from start to target (A* based).
  def find(start,target,max=30,ignore_objects=[])
    # needs to reinit

    target_node = Node.new target[0], target[1], target[2], nil,nil,nil,nil
    unless is_valid?(target_node,ignore_objects)
      # return nil if target unavailable
      return nil
    end

    start_node = Node.new start[0], start[1], start[2], nil,nil,nil,nil
    open = PriorityQueue.new(Node.new(start_node.x,start_node.y,start_node.z, :n, 0, Pathfinder.diagonal_heuristic(start_node,target_node), nil))
    @open = open

    #    create the closed list of nodes, initially empty
    closed_x = {}
    step = 1

    until open.empty? or step > max
      step += 1
      nh_node = open.best

      if nh_node.h == 0 
        # walk back up the parents of nh
        path = [] 
        path.unshift [nh_node.x,nh_node.y,nh_node.dir,nh_node.cost]
        parent = nh_node.parent
        until parent.nil?
          path.unshift [parent.x,parent.y,parent.dir,parent.cost]
          parent = parent.parent
        end
        # shift off start node
        path.shift
        return path
      else
        closed_x[nh_node.x] ||= []
        closed_x[nh_node.x] << nh_node
        neighbors = adjacent_nodes nh_node
        for neighbor in neighbors
          if is_valid? neighbor, ignore_objects

            # ignore the closed list, this could lead to a not shortest
            # path (meh...)
            closed_found = false
            closed_x_nodes = closed_x[neighbor.x]
            if closed_x_nodes
              for node in closed_x_nodes
                if node.y == neighbor.y 
                  closed_found = true
                end
              end
            end
            
            next if closed_found

            neighbor.h = Pathfinder.diagonal_heuristic(neighbor, target_node)

            open_neighbor = open.find(neighbor)

            if open_neighbor
              break if open_neighbor.h == 0
            else
              open.insert Node.new(neighbor.x,neighbor.y,neighbor.z,neighbor.dir,neighbor.cost,neighbor.h,nh_node)#[neighbor, ng, nh]
            end
          end
        end
      end
    end 

    nil
  end
end

# keeps a list of nodes sorted by its heuristic
class PriorityQueue
  attr_accessor :list, :x_list

  def initialize(initial_item = nil)
    @list = LinkedList.new initial_item
    @x_list = {}
    @x_list[initial_item.x] ||= []
    @x_list[initial_item.x] << initial_item
  end

  def find(n)
    nodes = @x_list[n.x]
    if nodes
      for node in nodes
        if node.x == n.x and node.y == n.y
          return node
        end
      end
    end
    return nil

#    found_node = nil
#    @list.each_element do |elem|
#      node = elem.obj
#      return nil if node.h > n.h # we know, since it is ordered
#      if node.x == n.x and node.y == n.y
#        found_node = node
#        break
#      end
#    end
#    found_node
  end

  def empty?()
    @list.empty?
  end

  def method_missing(name, *args)
    @list.send name, *args
  end

  def insert(nh)
    @x_list[nh.x] ||= []
    @x_list[nh.x] << nh

    elem = nil
    @list.each_element do |el|
      existing_nh = el.obj
      if existing_nh.h > nh.h
        elem = el
        break
      end
    end

    # place it
    if elem.nil?
      @list << nh
    else
      @list.place nh, :before, elem
    end

    @list
  end

  def best
    obj = @list.shift
    @x_list[obj.x].delete(obj) 
#    puts "BEST [#{obj.x},#{obj.y},#{obj.dir},#{obj.h}]"

    obj
  end
end

if $0 == __FILE__ #or true
  $: << '../lib'
  require 'linked_list'
  class Map
    def has_obstacle?(x, y, entity_z,ignore_me)
      if((x <= 15 and x >= 14) and (y >= 6))
        true
      else
        false
      end
    end
  end
  mappy = Map.new
  size = 80
  pf = Pathfinder.new(:foo, mappy, size, size)
  start = Time.now
  path = pf.find([16,15],[9,3], 99999)
  p(Time.now - start)
  puts "path size:[#{path.size}]" unless path.nil?
  p path
  p $timer
end

