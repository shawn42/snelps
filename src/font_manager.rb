class FontManager

  constructor :resource_manager

  def setup()
    TTF.setup()
    @font_cache = {}
    load_available_fonts
  end

  def load_available_fonts()
    available_fonts = @resource_manager.load_config 'fonts'
    available_fonts.each do |font_desc|
      @font_cache[font_desc[0]] ||= {}
      @font_cache[font_desc[0]][font_desc[2]] =
        @resource_manager.load_ttf_font font_desc[1], font_desc[2]
    end
  end

  def render(font_name,size,text,aa,fg_color)
    @font_cache[font_name][size].render text.to_s, aa, fg_color
  end
  
end
