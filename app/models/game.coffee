Spine = require('spine')

class Game extends Spine.Model
  @configure 'Game', 'numPlayed', 'signal', 'numOtherActed', 'reportConfirmed', 'result', 'numSignal0'
  
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