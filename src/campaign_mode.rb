require 'game_mode'

class CampaignMode < GameMode

  def start(*args)
    @map = nil

    require 'profile'
    # TODO use a 'local' connection
#    @network_manager.wrapped_session = 
#      @connection_manager.connect_to_server
    @network_manager.wrapped_session = 
      @connection_manager.connect_local

    @campaign = @resource_manager.load_campaign(args.shift)
    fire :music_play, :background_music

    @current_stage = @campaign[:stages].shift
    campaign_step @current_stage

    super
  end

  def campaign_step(stage)
    #    TODO RUBYGOO DIALOG
#    modal_dialog StoryDialog, stage[:before_story] do |d|
      start_next_map stage[:map]
#    end
  end

  def handle_map_script_victory
    # TODO add summary report page?
    p "VICTORY"

    @current_stage = @campaign[:stages].shift
    if @current_stage.nil?
      fire :mode_change, :main_menu
    else
      campaign_step @current_stage
    end
  end

  def handle_map_script_defeat
    # TODO add summary report page?
    p "DEFEAT"
    campaign_step @current_stage
  end
  
end
