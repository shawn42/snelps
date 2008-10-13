require 'rubygoo'

# handles displaying the mouse in campaign mode
class CampaignMouseView < Rubygoo::Widget

  def initialize(opts)
    @mouse = opts[:mouse]
    
    #TODO change this to come from theme props
    @cursor = opts[:resource_manager].load_image 'brush3.png'
    super opts
  end

  def draw(dest)
    if @mouse.dragging?
      dest.draw_box(@mouse.start_x, @mouse.start_y, @mouse.x, @mouse.y, Rubygoo::GooColor.css_color(:Green))
      sorted_x = [@mouse.x,@mouse.start_x].sort
      sorted_y = [@mouse.y,@mouse.start_y].sort
      x = sorted_x[0]
      y = sorted_y[0]
      w = sorted_x[1] - x
      h = sorted_y[1] - y
      dest.fill(Rubygoo::GooColor.css_color(:Green, 100), [x,y,w,h])
    end
    dest.draw_image(@cursor, @mouse.x-16, @mouse.y-16)
  end
end
