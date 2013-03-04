Spine = require('spine')

class Game extends Spine.Model
  @configure 'Game', 'reportConfirmed', 'result', 'currPlayerSignal', 'currPlayerReport', 'numOtherReportsConfirmed', 'numSignalZero'
  
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