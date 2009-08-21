add do
  gameplay_view do
    x 10
    y 30
    w 1024-60
    h 800-50
    visible false
  end

  label "Snelps" do
    x 60
  end

  label "5/20" do
    x 630
    y 20
    font_size 10
  end

  label "Vim 200" do
    x 680
    y 20
    font_size 10
  end

  label "Daub 200" do
    x 730
    y 20
    font_size 10
  end

  minimap_view do
    x 850
    y 150
    visible false
  end

  icon 'warrior_concept.png' do
    x 989
    y 0
    resize 0.2
  end

  widget do
    x 989
    y 0
    w Viewport::ACTIVE_EDGE_WIDTH
    h 800
    mouse_exit do
      @viewport.vx = 0
    end
    mouse_motion do
      @Viewport += Viewport::SCROLL_SPEED if mouse_over?
    end
  end
end
