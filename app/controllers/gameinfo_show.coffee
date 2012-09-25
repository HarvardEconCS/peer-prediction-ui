Spine = require('spine')

class GameinfoShow extends Spine.Controller
  constructor: ->
    super
    
    for record in @game.privateInfo
      @currPlayerSignal = record.signal if record.playerTurkId is @turkId
               
    @render()

  render: ->
    @html require('views/gameinfo')
      numTotal: @game.numTotal
      numPlayers: @game.numPlayers
      numRemaining: @game.numRemaining
      signal: @currPlayerSignal
                
module.exports = GameinfoShow