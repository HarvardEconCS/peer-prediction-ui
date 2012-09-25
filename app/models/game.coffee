Spine = require('spine')

class Game extends Spine.Model
  @configure 'Game', 'numTotal', 'numRemaining', 'numPlayers', 'playersId', 'privateInfo', 'results'

  @extend @Local

  @newGame: () ->
    
    # start a new game
    Game.destroyAll()

    turkIds = ['turkId1', 'turkId2', 'turkId3']
    signalList = ['Red', 'Green']
    privateInfo = []
    for id in turkIds
      i = Math.floor(Math.random() * signalList.length)
      privateInfo.push
        playerTurkId: id
        signal: signalList[i]

    g = Game.create
      numTotal: 2
      numRemaining: 1
      numPlayers: 3
      playerTurkIds: turkIds
      privateInfo: privateInfo
      results: 'results of previous games'
    g.save()

    console.log("current game is #{JSON.stringify(Game.first())}")

    Game.fetch()

    # We would get the game data from the server


                                                                   
module.exports = Game