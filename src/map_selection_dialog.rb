class MapSelectionDialog < Rubygoo::Dialog
  extend Publisher
  can_fire :load, :cancel

  def initialize(opts)
    super opts
    
    title = Rubygoo::Label.new "Create a server", :x=>30,:y=>5, :relative => true
    add title

    map_label = Rubygoo::Label.new "Map:", :x=>20,:y=>60, :relative => true
    add map_label
    
    map_field = Rubygoo::TextField.new 'obs', :relative => true, :x => 80, :y => 60
    add map_field
    
    cancel_button = Rubygoo::Button.new "Cancel", :x=>150,:y=>250,:relative=>true
    cancel_button.when :pressed do |b|
      close
      fire :cancel
    end
    add cancel_button

    ok_button = Rubygoo::Button.new "Start", :x=>50,:y=>250,:relative=>true
    ok_button.when :pressed do |b|
      fire :load, map_field.text
      close
    end
    add ok_button
  end
  
  def update_rect()
    super
  end

  def key_released(event)
    close if event.data[:key] == K_ESCAPE
  end
end