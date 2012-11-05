Spine = require('spine')

Network = require 'network'
Game    = require 'models/game'

class Task extends Spine.Controller
  className: "task"

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
    
    @randomRadio = Math.floor(Math.random() * 2)
    console.log "radio order may change, #{@randomRadio}"
    
    Network.setControllers @
        
  active: (params)->
    super
    Network.ready()    
    @render()
        
  render: ->
    return unless @isActive()
    
    @payAmounts = Network.payAmounts    
    @numTotal = Network.numTotal
    @numPlayers = Network.numPlayers
    
    @game = Game.last()
    @games = Game.all()
    
    @html require('views/task')(@)

    if @randomRadio is 0
      $('input:radio#firstRadio').val("#{Network.signalList[0]}")
      $('img#imgFirstRadio').attr('src', "#{Network.signalList[0]}.jpeg")
      $('input:radio#secondRadio').val("#{Network.signalList[1]}")
      $('img#imgSecondRadio').attr('src', "#{Network.signalList[1]}.jpeg")      
    else
      $('input:radio#firstRadio').val("#{Network.signalList[1]}")
      $('img#imgFirstRadio').attr('src', "#{Network.signalList[1]}.jpeg")
      $('input:radio#secondRadio').val("#{Network.signalList[0]}")
      $('img#imgSecondRadio').attr('src', "#{Network.signalList[0]}.jpeg")

    $('div .resultTable').scrollTop($('div .resultTable').prop("scrollHeight"))


  # called after getting the game state
  gotGameState: (gameState) ->
    Game.saveGame(gameState)

    # reset these for rendering
    @revealSignal = false 
    @selected = @defaultReport
    @confirmed = false

    @randomRadio = Math.floor(Math.random() * 2)
    console.log "radio order may change, #{@randomRadio}"

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

module.exports = Task