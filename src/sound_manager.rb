class SoundManager
  attr_reader :enabled

  constructor :resource_manager
  def setup()
    # Not in the pygame version - for Rubygame, we need to 
    # explicitly open the audio device.
    # Args are:
    #   Frequency - Sampling frequency in samples per second (Hz).
    #               22050 is recommended for most games; 44100 is
    #               CD audio rate. The larger the value, the more
    #               processing required.
    #   Format - Output sample format.  This is one of the
    #            AUDIO_* constants in Rubygame::Mixer
    #   Channels -output sound channels. Use 2 for stereo,
    #             1 for mono. (this option does not affect number
    #             of mixing channels) 
    #   Samplesize - Bytes per output sample. Specifically, this
    #                determines the size of the buffer that the
    #                sounds will be mixed in.
#    Rubygame::Mixer::open_audio( 22050, Rubygame::Mixer::AUDIO_U8, 2, 1024 )
    Rubygame::Mixer::open_audio( 22050, nil, 2, 1024 )

    puts 'Warning, sound disabled' unless
      (@enabled = (Rubygame::VERSIONS[:sdl_mixer] != nil))
    if @enabled
      STDOUT.puts "loading background music..."
      # TODO change this to be a hash of sounds for easier coding later
      @background_music = @resource_manager.load_music("snelps_jungle.wav")
      @background_music.fade_in 3
      @background_music.fade_out 3

      @unit_move = @resource_manager.load_sound("whiff.wav")

      @menu_music = @resource_manager.load_music("loop.wav")
      @menu_music.fade_in 3
      @menu_music.fade_out 3
      STDOUT.write "done.\n"
    end
  end 

  def play_sound(what)
    if @enabled
      case what
      when :unit_move
        # TODO change to use new Mixer::Sound class
        @sound_thread = Thread.new do
          # TODO, why doesn't this play?
          @unit_move.play -1
        end
      end
    end
  end

  def play(what)
    if @enabled
      case what
      when :ingame_background
        # TODO change to use new Mixer::Music class
        @sound_thread = Thread.new do
          @background_music.play -1
  #        Rubygame::Mixer::play(background_music,-1,-1)
        end
      when :menu_music
        # TODO change to use new Mixer::Music class
        @sound_thread = Thread.new do
          @menu_music.play -1
        end
      end
    end
  end

  def stop(what)
    if @enabled
      case what
      when :ingame_background
        # TODO change to use new Mixer::Music class
        @background_music.stop
      when :menu_music
        @menu_music.stop
      end
    end
  end

end
