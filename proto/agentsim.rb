#require "fps_controller.rb"
require 'yaml'
require "rubygame"
include Rubygame

class Action
  attr_accessor :name
  attr_writer :predicate, :action

  def initialize(name, predicate, &block)
    @name = name
    @predicate = predicate
    @action = block
  end

  def perform
    @action.call
  end

  def predicate?
    return  @predicate.call
  end
end

class Agent
  attr_accessor :draw_glyph, :x, :y, :x_vel, :y_vel
  attr_accessor :actions, :predicates
  attr_accessor :partner, :captured, :hits, :dead

  def initialize
    @actions = []
    @partner = nil
    @captured = false
    @dead = false
    @hits = 0 
    @predicates = {}
  end

  def tick
    perform_all_actions
    self.x += x_vel
    self.y += y_vel
    self.x_vel *= 0.999
    self.y_vel *= 0.999
  end

  def perform_all_actions
    for action in actions
      action.perform if action.predicate?
    end
  end

  def condition(name, &block)
    predicates[name] = block
  end

  def add_action(name, predicate_list, &block)
    predicate_list.each do |predicate|
      actions << Action.new(name, predicates[predicate], &block)
    end    
  end
end

class Sim

  def initialize(params, fps_controller = nil)
    @width = params[:width]
    @height = params[:height]
    @fps = params[:target_fps]
    @fps_controller = fps_controller
    @population = params[:population]

    Rubygame.init()

    @queue = EventQueue.new() # new EventQueue with autofetch
    @queue.filter = [ActiveEvent]
    @clock = Rubygame::Time::Clock.new()
    @clock.desired_fps = @fps

    @screen = Screen.set_mode([@width,@height])
    @screen.set_caption("Sim","simmy")
    @display = Surface.new [@width, @height]
    @agents = []
    @dirty_list = {}
  end

  def create_agents
    colors = [rand(20)+128,rand(20)+150, rand(20)+192].sort
    @population.times do
      agent = Agent.new
      color = colors.map {|x| colors[rand(colors.size)] }
      agent.draw_glyph = Proc.new { plot agent, [agent.x, agent.y], color }
      agent.x = rand @width
      agent.y = rand @height
      agent.x_vel = (rand * 3.0) - 1.5
      agent.y_vel = (rand * 3.0) - 1.5

      train agent
      @agents << agent
    end
  end

  def plot(agent, coord, color)
    @dirty_list[agent] = coord
    draw_shape coord, color
  end

  def train(agent)
    agent.condition(:x_max) { agent.x > @width }
    agent.condition(:y_max) { agent.y > @height }
    agent.condition(:x_min) { agent.x < 0.0 }
    agent.condition(:y_min) { agent.y < 0.0 }
    agent.condition(:dead) { agent.hits > 3 }
    agent.condition(:too_close) do
      found = false
      @agents.each do |other|
        unless other === agent || other.captured || other.dead
          if (other.x - agent.x).abs < 4.0 && (other.y - agent.y).abs < 4.0
            agent.partner = other
            found = true
            agent.hits += 1
          end
        end
      end
      found
    end

    agent.add_action :bounce_x, [:x_max, :x_min] do
      agent.x_vel = - agent.x_vel
    end

    agent.add_action :bounce_y, [:y_max, :y_min] do
      agent.y_vel = - agent.y_vel
    end

    agent.add_action :avoid, [:too_close] do
      #agent.y_vel = agent.y_vel * 0.5 + agent.partner.y_vel * 0.8
      #agent.x_vel = agent.x_vel * 0.5 + agent.partner.x_vel * 0.8
      agent.partner.x_vel = agent.partner.x_vel * -(1 + (agent.partner.x - agent.x).abs/15.0)
      agent.partner.y_vel = agent.partner.y_vel * -(1 + (agent.partner.y - agent.y).abs/15.0)
      agent.y_vel = agent.y_vel * 0.98
      agent.x_vel = agent.x_vel * 0.98

      #agent.partner.captured = true
      #agent.captured = true
      #old_glyph = agent.draw_glyph.clone
      #agent.draw_glyph = Proc.new do
      #old_glyph.call
      #  @display.plot [agent.x-1, agent.y-1], [255,0,0]
      #end
    end

    agent.add_action :stop, [:dead] do
      agent.dead = true
      agent.x_vel = 0.0
      agent.y_vel = 0.0
      agent.draw_glyph = Proc.new { plot agent, [agent.x, agent.y], [255,0,0]}
    end
  end

  def box_around(coord)
    [coord[0]-4, coord[1]-4, 8, 8]
  end

  def erase_shape(coord, color)
    box = box_around(coord)
    Draw.filled_box @display, box[0..1],box[2..3], color
  end

  def draw_shape(coord, color)
    Draw.circle(@display, coord, 2, color)
    Draw.filled_box @display, coord.map{|c|c - 1}, [3,3], color
  end

  def erase_dirty
    @dirty_list.each_value do |coord|
      erase_shape coord, [0,0,0]
    end
    @dirty_list.clear
  end

  def tick_agents
    @agents.each do |agent|
      agent.tick unless agent.dead
      agent.draw_glyph.call
    end
  end

  def run
    catch(:rubygame_quit) do
      loop do
        @queue.each do |event|
          case event
          when KeyDownEvent
            case event.key
            when K_ESCAPE
              throw :rubygame_quit 
            when K_Q
              throw :rubygame_quit 
            when KeyUpEvent
            when QuitEvent
              throw :rubygame_quit
            end
          end
        end
        erase_dirty
        #@display.fill [0,0,0]
        tick_agents
        @display.blit(@screen, [0,0])
        @screen.flip
        #      snelps.draw(screen)
        @screen.update()
        update_time = @clock.tick()
      end
    end
  end
end


params = {
  :width => 500,
  :height => 300,
  :target_fps => 60,
  :population =>100
}

#fps_controller = FPSController.new
sim = Sim.new params#, fps_controller

sim.create_agents
sim.run
