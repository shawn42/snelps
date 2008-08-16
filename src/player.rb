# represents a player in the game
class Player
  SNELPS = [:fire, :earth, :wind, :water]
  constructor :snelp, :server_id, :local
  attr_accessor :vim, :daub, :snelp, :server_id, :local

  def setup()
    @vim = 0
    @daub = 0
  end
end
