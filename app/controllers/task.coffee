Spine = require('spine')

Network = require 'network'
Game    = require 'models/game'

class Task extends Spine.Controller
  className: "task"

  events:
    'click .getsignal': 'revealSignalFunc'  # button to reveal signal
    'click .confirm'  : 'confirmReport'     # button to confirm report
    'click .exit'     : 'goToExitSurvey'    # button to go to exit survey 
    'change input:radio:checked' : 'radioChanged'

  constructor: ->
    super
    @confirmMsg     = Network.confirmMsg
    @unconfirmMsg   = Network.unconfirmMsg
    @defaultReport  = Network.defaultOption        
    @signalList     = Network.signalList
    
    @revealSignal = false
    @selected = @defaultReport
    
    # default to displaying aggregate information for now
    @agg = true
    
    # order of radio buttons may change
    @randomRadio = Math.floor(Math.random() * 2)
    
    Network.setControllers @
        
  # called when this controller is activated in the stack
  active: (params)->
    super
    Network.ready()    
    @render()
        
  render: ->
    return unless @isActive()
    
    @payAmounts = Network.payAmounts    
    @numTotal   = Network.numTotal
    @numPlayers = Network.numPlayers
    
    @game   = Game.last()
    @games  = Game.all()
    
    @html require('views/task')(@)

    # add left and right dashed border style for the last row
    $('tr.borderAroundDashed td:first-child').addClass('borderLeftDashed')
    $('tr.borderAroundDashed td:last-child').addClass('borderRightDashed')

    # random order of the radio buttons
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

    # make the table always scroll to the bottom
    $('div .resultTable').scrollTop($('div .resultTable').prop("scrollHeight"))


  # called after getting the game state
  gotGameState: (gameState) ->
    Game.saveGame(gameState)

    # reset these for rendering
    @revealSignal = false 
    @selected = @defaultReport
    @confirmed = false

    # order of radio buttons may change
    @randomRadio = Math.floor(Math.random() * 2)

    @render()
    

  # called when games are finished
  finish: ->
    @finished = true
    @render()
    
    # game is finished, remove the dashed border around the current game
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
    
    # if the player hasn't revealed the candy yet, 
    if @revealSignal is false
      alert("Please look at your candy first before choosing your report!")
      @selected = @defaultReport # reset selected report
      @render()
      return
    
    # the player hasn't selected a report yet
    if @selected is @defaultReport
      alert("Please choose a color to report!")
      return

    # the player has confirmed a valid report
    @game = Game.last()
    if @game.result?
      @game.result[0].action = @selected
    else 
      @game.result = [ 
        {'action': @selected}
      ]
    @game.save()
    
    # set flag for rendering
    @confirmed = true
    
    @render()
        
    # start next game if all players have acted 
    if @game.otherActed is (Network.numPlayers - 1)
      clearInterval(Network.intervalId)
      Network.getGameResult()
    
  helper: (msg) ->
    console.log msg
    
  # go to the exit survey
  goToExitSurvey: (e) ->
    e.preventDefault()
    @navigate '/exit'

module.exports = Task