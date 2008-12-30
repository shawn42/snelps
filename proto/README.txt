Tue Dec 30 12:00:28 EST 2008
crosby

Open several terminals, lay them out so all are visible.
In a terminal:
  ruby server.rb

In others:
  ruby client.rb

Overview:

server.rb
  Server, GameHub, GameSession

  Server class publishes a GameHub instance on DRb.

  GameHub#join
    Starts a GameSession for the new player
  
  GameSession is the API used by the server to push messages to
  a client, AND it's the API used by a client to msg the server.
  GameSession also knows the player number assigned by the server.

  This model could allow for private conversations between client and
  server, since the instance of a GameSession within the game hub is
  a representation of a specific individual player.  Right now, the
  hub is treating the sessions anonymously but you could easily map
  the sessions by player number as well.

  GameSession has a quit function for use by the client.

client.rb
  Client, WrappedGameSession

  Client#run
    Connect to server
    Join game
    Wrap a Communicator around the GameSession
    Subscribe for incoming messages
    Generate some random chatter
    Quit game

  WrappedGameSession
    Delegates most methods to wrapped @game_session object
    Allows subscription to incoming messages
    Spins a Thread that pulls messages via @game_session.next_message

Why wrap the game session on the client side?
  Mainly: so we can use Publisher to subscribe for incoming messages, which involves spinning a thread.
  Beyond that, it will be much easier to manage the usage of server functionality if the client has a single point of contact.
  (Right now the object we get over DRb does so much of the work, but if you were to reimplement the comm layer, you'd 
  have to do things differently to support #quit and #player_number.)

Remodeling NetworkManager:
  I would create something like GameJoiner or ConnectionManager or whatever, when the user decides to connect to
  a server, or decides to play locally, does the work of getting a WrappedGameSession and setting it into NetworkManager.
  Then implement an alternate to WrappedGameSession for local play.
  This way, NetworkManager just operates on this object (wherever it came from) without thinking differently about how to connect,
  or what kind of game is being played.
  (Imagine testing NetworkManager... if he owns the connection logic and the decision logic for using a locally stubbed session,
  the only way to exercise those branches is by running him through all the setup paces, then trying all his behavior for each mode. Yuk.)
