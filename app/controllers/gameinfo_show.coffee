Spine = require('spine')
Network = require 'network'
Game = require('models/game')

class GameinfoShow extends Spine.Controller
  className: "info"

  events:
    'click button': 'chooseAction'

  elements:
    'select' : 'select'
  
  constructor: ->
    super
    
  gotGameState: ->
    @game = Game.first()
    @render()
		
  render: ->
    return unless @game
    @numNotActed = 0
    @html require('views/gameinfo')(@)

  chooseAction: (e) ->
    e.preventDefault()
    @action = @select.val()
    if @action is "Please select a color"
      alert("Please choose a color to report!")
      @action = null
    console.log("Chosen action is", @action)
    @render()
  
    # TODO: send action to the server
    Network.sendAction @action

                
module.exports = GameinfoShow