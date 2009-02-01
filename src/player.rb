require 'commands'
include Commands
# represents a player in the game
class Player
  SNELPS = [:fire, :earth, :wind, :water]

  constructor :snelp, :server_id, :local
  attr_accessor :vim, :daub, :snelp, :server_id, :local

  def setup()
    @vim = 0
    @daub = 0
  end

  # creates the player join command for the server to digest.
  # snelp is the type of snelp this player is representing in the game
  def self.create_player_cmd(snelp,player_id)
    [PLAYER_JOIN,SNELPS.index(snelp),player_id].join ":"
  end
end
