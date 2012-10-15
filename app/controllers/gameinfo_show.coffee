Spine = require('spine')
Network = require 'network'
Game = require('models/game')

class GameinfoShow extends Spine.Controller
  className: "info"

  events:
    'click .confirm':   'chooseAction'
    'click .getsignal': 'getSignal'
    'click .exit': 'exit'
    'change select': 'selectChanged'

  elements:
    'select':   'select'
    '#signal':  'signalLabel'
    '#signalMessage': 'signalMessage'

  constructor: ->
    super
    @showMessage = false
    @action = null
    @defaultReport = 'default'
    @finished = false
    @payAmounts = null

  render: ->
    @payAmounts = Network.payAmounts
    @html require('views/gameinfo')(@)

  selectChanged: ->
    @selected = @select.val()

  # called after getting the game state
  gotGameState: (info) ->
    @finished = if info.finished then info.finished else null
    unless @finished
      Game.saveGame(info.gameState)
      @game = Game.first()
      @showMessage = false 
      @action = null
      @selected = @defaultReport

    @render()

  # called after getting the new status
  gotStatus: (newStatus) ->
    console.log "changing status from #{@game.otherStatus} to #{newStatus}"
    
    @game.otherStatus = newStatus if @game
    @game.otherActed = 0
    @game.otherActed += 1 for status in @game.otherStatus when status is true
    
    @game.save()
    Game.fetch()
    @game = Game.first()
    @render()
		
  # if player clicks button to select a candy
  getSignal: (e) ->
    e.preventDefault()
    @showMessage = true
    @render()

  # if player clicks button to confirm action
  chooseAction: (e) ->
    e.preventDefault()
    
    if @select.val() is @defaultReport
      alert("Please choose a color to report!")
      return
    
    if @showMessage is false
      alert("Please select a candy first!")
      @selected = @defaultReport # if the player hasn't selected the candy yet, then reset the selected choice to default
      @render()
      return

    @action = @select.val()    
    Network.action = @action
    @render()

  exit: (e) ->
    e.preventDefault()
    @navigate '/exit'
                
module.exports = GameinfoShow