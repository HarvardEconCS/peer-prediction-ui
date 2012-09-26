Spine = require('spine')

class Game extends Spine.Model
  @configure 'Game', 'numTotal', 'numRemaining', 'numPlayers', 'signal'

  @extend @Local

  @getGameState: () ->

    # game state received from the server
    signalList = ['Red', 'Green']
    i = Math.floor(Math.random() * signalList.length)

    receivedGameState =
      numTotal: 2
      numRemaining: 1
      numPlayers: 3
      turkId: 'turkId3'
      signal: signalList[i] # randomly selected for now

    @createGame(receivedGameState)

  @createGame: (receivedGameState) ->
                  
    # start a new game
    Game.destroyAll()
    g = Game.create(receivedGameState)
    g.save()
    
    console.log("current game is #{JSON.stringify(Game.first())}")
    Game.fetch()

                                                                   
module.exports = Game