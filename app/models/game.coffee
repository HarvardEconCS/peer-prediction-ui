Spine = require('spine')

class Game extends Spine.Model
  @configure 'Game', 'numPlayed', 'signal', 'otherActed', 'otherStatus', 'result'

  # @extend @Local
  
  @init: ->
    Game.destroyAll()
    
  @saveGame: (gameState) ->
    g = Game.create(gameState)
    g.save()
                        
  @saveResult: (resultInfo) ->
    g = Game.last()
    g.result = resultInfo
    g.save()
                                                 
module.exports = Game