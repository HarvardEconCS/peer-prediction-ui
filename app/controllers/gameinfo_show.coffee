Spine = require('spine')

Game = require('models/game')

class GameinfoShow extends Spine.Controller

  events:
    'click button': 'chooseAction'

  elements:
    'select' : 'select'
  
  constructor: ->
    super

    @game = Game.first()
    
    # get number of other players not chosen an action
    @numNotActed = @game.numPlayers - 1
    
    @render()

  render: ->
    @html require('views/gameinfo')
      numTotal: @game.numTotal
      numPlayers: @game.numPlayers
      numRemaining: @game.numRemaining
      signal: @game.signal
      action: @action
      numNotActed: @numNotActed
      numOpps: @game.numPlayers - 1

  chooseAction: (e) ->
    e.preventDefault()
    @action = @select.val()
    if @action is "Please select a color"
      alert("Please choose a color to report!")
      @action = null
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