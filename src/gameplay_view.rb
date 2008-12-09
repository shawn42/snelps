require 'rubygoo'
class GameplayView < Rubygoo::Widget

  # Health box sizes
  HB_HEIGHT = 2
  HB_WIDTH = 20

  attr_writer :map, :entity_manager, :fog, :viewport
  def initialize(opts)
    super opts
    @green = Rubygoo::GooColor.color :Green
    @chartreuse = Rubygoo::GooColor.color :Chartreuse
    @red = Rubygoo::GooColor.color :Red
  end

  def viewport=(vp)
    @w = vp.width
    @h = vp.height
    @viewport = vp
    update_rect
  end

  def draw(adapter)
    # TODO change all of these to be rubygoo safe
    # TODO should I pull the map image creation up to here?
    @map.recreate_map_image unless @map.background_image

    adapter.draw_partial_image @map.background_image, @x,@y, @viewport.x_offset,@viewport.y_offset,@viewport.width,@viewport.height

    draw_ents adapter

    adapter.draw_partial_image @fog.mask_image, @x,@y, @viewport.x_offset,@viewport.y_offset,@viewport.width,@viewport.height
  end

  def draw_ent(adapter,ent)
    vx,vy = @viewport.world_to_view ent.x+@x, ent.y+@y

    ht = @map.half_tile_size
    ts = @map.tile_size

    if ent.respond_to? :size and ent.size
      pixel_width = (ent.size[0] * ts)
      pixel_height = (ent.size[1] * ts)
      ent.w_offset ||= (ent.image.size[0] - pixel_width)/2 + ht
      ent.h_offset ||= (ent.image.size[1] - pixel_height)/2 + ht
      draw_x = vx-ent.w_offset
      draw_y = vy-ent.h_offset
      half_width = pixel_width/2
      selection_x = draw_x+half_width
      selection_y = draw_y+pixel_height/2
      selection_radius = half_width
    else
      draw_x = vx-ent.image.w/2
      draw_y = vy-ent.image.w/2
      selection_x = draw_x+ht
      selection_y = draw_y+ht
      selection_radius = ht
    end

    # can I pull this out into a selectable componenet?
    # selection indicator
    if ent.is? :selectable and ent.selected?
      adapter.draw_circle(selection_x,selection_y,selection_radius,@chartreuse)
    end

    dx,dy,sx,sy,sw,sh = clip_ent(draw_x, draw_y, ent)

    # ent image
    adapter.draw_partial_image ent.image, dx,dy,sx,sy,sw,sh unless sw < 1 or sh < 1

    # health box
    if ent.is? :selectable and ent.selected?
      hb_x = selection_x-HB_WIDTH/2
      hb_y = vy - 20

      adapter.fill(hb_x,hb_y,
        hb_x+HB_WIDTH,hb_y+HB_HEIGHT, @red)

      hb_fill = ent.health/ent.class.default_health * HB_WIDTH
      adapter.fill(hb_x,hb_y,
        hb_x+hb_fill,hb_y+HB_HEIGHT, @green)
    end

  end

  def clip_ent(draw_x, draw_y, ent)
    dx = draw_x
    dy = draw_y
    sx = 0
    sy = 0
    sw = ent.image.w
    sh = ent.image.h

    rs = dx+sw
    ls = dx
    ts = dy
    bs = dy+sh

    if rs >= @rect.right
      sw -= (rs-@rect.right)
    elsif ls < @rect.left
      cl = @rect.left-ls
      sw -= cl
      dx += cl
      sx += cl
    end

    if bs > @rect.bottom
      sh -= (bs-@rect.bottom)
    elsif ts <= @rect.top
      ct = @rect.top-ts
      sh -= ct
      dy += ct
      sy += ct
    end

    return dx,dy,sx,sy,sw,sh
  end

  def draw_ents(adapter)
    @entity_manager.available_z_levels.each do |az|
      if @entity_manager.viewable_entities_dirty
        @entity_manager.viewable_entities[az] = []
        @entity_manager.occupancy_grids[az].get_occupants_by_range(@entity_manager.viewable_rows,@entity_manager.viewable_cols).each do |ze|
          @entity_manager.viewable_entities[az] << ze
        end
      end
      for ze in @entity_manager.viewable_entities[az]
        draw_ent adapter, ze
      end
    end
    # TODO any race conditions here??
    @entity_manager.viewable_entities_dirty = false 
  end

  def mouse_up(event)
    if @mini_map and @mini_map.hit_by? event.data[:x], event.data[:y]
      @mini_map.handle_mouse_click event
    else
      @entity_manager.handle_mouse_click event
    end
  end

  def mouse_drag(event)
    @entity_manager.handle_mouse_drag event
  end

  def update(time)
    @map.update time
    @entity_manager.update time
    @map.update time unless @map.nil?
    @viewport.update time unless @viewport.nil?
    @entity_manager.update time unless @entity_manager.nil?
#    @abilities_panel.update time unless @abilities_panel.nil?

  end

end
