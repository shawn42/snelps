require 'publisher'
require 'dialog'
require 'story_stack'
class StoryDialog < Dialog
  extend Publisher
  can_fire :destroy_modal_dialog

  def setup(*args)
    @story = args.shift

    @layout = AbsoluteLayout.new self, @font_manager

    stack = StoryStack.new @layout, @story do 
      apply
      close
    end
    @layout.add stack, 0, 0
  end

  def on_key_up(event)
    case event.key
    when K_ESCAPE
      close
    when K_Q
      close
    else
      @layout.key_up event
    end
  end
end
