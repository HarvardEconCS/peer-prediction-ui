Spine = require('spine')

class GameinfoShow extends Spine.Controller

  events:
    'submit form': 'chooseAction'

  elements:
    'select' : 'select'
  
  constructor: ->
    super

    # get signal
    for record in @game.privateInfo
      @currPlayerSignal = record.signal if record.playerTurkId is @turkId

    # get number of other players not chosen an action
    @numNotActed = @game.numPlayers - 1
    
    @render()

  render: ->
    @html require('views/gameinfo')
      numTotal: @game.numTotal
      numPlayers: @game.numPlayers
      numRemaining: @game.numRemaining
      signal: @currPlayerSignal
      action: @action
      numNotActed: @numNotActed
      numOpps: @game.numPlayers - 1

  chooseAction: (e) ->
    e.preventDefault()
    @action = @select.val()
    console.log("Chosen action is", @action)
    @render()
  
    # TODO: send action to the server
    ###
    # $.post
    #   url: 'save_action'
    #   data: {turkId: @turkId, action: @action}
    #   dataType: 'json'
    #   success: -> console.log("successfully sent action to server")
    ###
                
module.exports = GameinfoShow