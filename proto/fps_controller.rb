require 'RUDL'
include RUDL

class FPSController

  DELTA = 5
  CORRECTION_CAP = 500
  
  def at_fps(rate=20)
    if !block_given?
      return
    end
    correction=1000.0/rate
    start = Time.now
    last_sec = start.sec
    frames = 0
    #log = []
    loop do
      
      yield
      Timer.delay correction
      
      frames+=1
      if last_sec < Time.now.sec
        last_sec = Time.now.sec
        #log << "tick"
        if frames < rate
          correction -= DELTA
        end
        if frames > rate
          correction += DELTA
        end
        
        if correction <= 0
          correction = 0
        end
        if correction > CORRECTION_CAP
          correction = CORRECTION_CAP
        end
        
        #puts "FPS: #{frames}, #{correction}"
        #log.each do |l| puts l end
        #log.clear
        #STDOUT.flush
        frames = 0
      end
    end
  end
end