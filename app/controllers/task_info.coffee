Spine = require('spine')
Network = require 'network'

Game    = require 'models/game'

class TaskInfo extends Spine.Controller
  className: "info"

  events:
    'click .getsignal': 'revealSignalFunc'  # button to reveal signal
    'click .confirm'  : 'confirmReport' # button to confirm report
    'click .exit'     : 'goToExitSurvey'# button to go to exit survey 
    'change input:radio:checked' : 'radioChanged'

  constructor: ->
    super
    @confirmMsg = "Yes"
    @unconfirmMsg = "No"
    @defaultReport = Network.defaultOption        
    @signalList = Network.signalList
    
    @revealSignal = false
    @selected = @defaultReport
        
  render: ->
    @payAmounts = Network.payAmounts    
    @numTotal = Network.numTotal
    @numPlayers = Network.numPlayers
    
    @game = Game.last()
    @games = Game.all()
    
    @html require('views/task-info')(@)


  # called after getting the game state
  gotGameState: (gameState) ->
    Game.saveGame(gameState)

    # reset these for rendering
    @revealSignal = false 
    @selected = @defaultReport
    @confirmed = false

    @render()

  # called when games are finished
  finish: ->
    @finished = true
    @render()
    $('tr').removeClass("borderAroundDashed")
    $('td').removeClass("borderLeftDashed")
    $('td').removeClass("borderRightDashed")
    
  # if player clicks button to reveal the selected candy
  revealSignalFunc: (e) ->
    e.preventDefault()
    @revealSignal = true

    @render()

	# called when selected report is changed
  radioChanged: ->
    @selected = $('input:radio:checked').val()

  # if player clicks button to confirm action
  confirmReport: (e) ->
    e.preventDefault()
    
    # if the player hasn't selected the candy yet, 
    if @revealSignal is false
      alert("Please look at your candy first before choosing your report!")
      @selected = @defaultReport # reset selected report
      @render()
      return
    
    if @selected is @defaultReport
      alert("Please choose a color to report!")
      return

    # player has confirmed a valid report
    @game = Game.last()
    if @game.result?
      @game.result[0].action = @selected
    else 
      @game.result = [ 
        {'action': @selected}
      ]
    @game.save()
    
    @confirmed = true
    @render()
    
    # check if other players have acted
    allOthersFinished = true
    for i in [0..(Network.numPlayers - 2)]
      if @game.otherStatus[i] is false
        allOthersFinished = false
        
    # start next game if all players have acted 
    if allOthersFinished is true
      clearInterval(Network.intervalId)
      Network.nextGame()
    
  helper: (msg) ->
    console.log msg
    
  # go to the exit survey
  goToExitSurvey: (e) ->
    e.preventDefault()
    @navigate '/exit'

module.exports = TaskInfo