Spine = require('spine')

class CurrplayerShow extends Spine.Controller
  constructor: ->
    super
    @active @render()

  render: ->
    unless @currPlayerAction.signal
      signalList = ["Red", "Green"]
      signalIndex = Math.floor(Math.random() * 2);
      @currPlayerAction.signal = signalList[signalIndex]
      @currPlayerAction.save()
    @html require('views/currplayerinfo')({signal: @currPlayerAction.signal})
    console.log("curr player action #{JSON.stringify(@currPlayerAction)}")
                                    
module.exports = CurrplayerShow