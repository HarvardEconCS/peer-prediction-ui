Spine = require('spine')

class Game extends Spine.Model
  @configure 'Game', 'numTotal', 'numPlayed', 'numPlayers', 'signal', 'otherPlayerIds', 'otherActed', 'otherStatus'

  @extend @Local
    
  @saveGame: (gameState) ->
    Game.destroyAll()
    g = Game.create(gameState)
    g.save()
    Game.fetch()
                                                                       
module.exports = Game