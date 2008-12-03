class SoundManager
  attr_reader :enabled

  constructor :resource_manager, :config_manager
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
    @enabled = (@enabled and (@config_manager.settings[:sound].nil? or @config_manager.settings[:sound] == true))

    if @enabled
      STDOUT.puts "loading background music..."
      STDOUT.puts "TODO, load sounds/music from config file"
      @music = {}
      @music[:background_music] = @resource_manager.load_music("Ethan1.ogg")
      @music[:background_music].fade_out 3
      @music[:menu_music] = @resource_manager.load_music("loop.ogg")
      @music[:menu_music].fade_out 3


      @music[:intro_music] = @resource_manager.load_music("intro.ogg")
      @music[:intro_music].fade_out 3


      @sounds = {}
      @sounds[:move] = @resource_manager.load_sound("whiff.ogg")
      @sounds[:attack] = @resource_manager.load_sound("attack.ogg")
      @sounds[:death] = @resource_manager.load_sound("death.ogg")

      STDOUT.write "done.\n"
    end
  end 

  def play_sound(what)
    if @enabled
      @sound_thread = Thread.new do
        @sounds[what].play if @sounds[what]
      end
    end
  end

  def play(what)
    if @enabled
      @sound_thread = Thread.new do
        puts "playing #{what}"
        @music[what].play :repeats => -1 if @music[what]
      end
    end
  end

  def stop(what)
    if @enabled
        puts "stopping #{what}"
      @music[what].stop if @music[what]
    end
  end

end
