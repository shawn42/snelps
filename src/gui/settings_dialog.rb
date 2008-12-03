require 'publisher'
class SettingsDialog < Rubygoo::Dialog
  extend Publisher
  can_fire :save

  attr_accessor :settings
  def initialize(opts)
    super opts
    @settings = opts[:settings]

    title = Rubygoo::Label.new "Snelps Settings", :x=>30,:y=>5, :relative => true
    add title

    # TODO add labels to checkboxes
    sound_check = Rubygoo::CheckBox.new :label=>"Sound enabled", :checked => @settings[:sound], :x=>30, :y=> 80, :w=>20, :h=>20, :relative=>true
    sound_check.on :checked do |c|
      @settings[:sound] = c.checked?
    end
    add sound_check

    fs_check = Rubygoo::CheckBox.new :label=>"Fullscreen", :checked => @settings[:fullscreen], :x=>30, :y=> 130, :w=>20, :h=>20, :relative=>true
    fs_check.on :checked do |c|
      @settings[:fullscreen] = c.checked?
    end
    add fs_check

    cancel_button = Rubygoo::Button.new "Cancel", :x=>150,:y=>400,:relative=>true
    cancel_button.when :pressed do |b|
      close
    end
    add cancel_button

    ok_button = Rubygoo::Button.new "OK", :x=>50,:y=>400,:relative=>true
    ok_button.when :pressed do |b|
      fire :save, self
      close
    end
    add ok_button
  end

  def key_released(event)
    close if event.data[:key] == K_ESCAPE
  end
end
