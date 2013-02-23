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
    'click a#slide' : "slideToggleClicked"

  constructor: ->
    super
    @unconfirmMsg   = Network.unconfirmMsg
    @defaultReport  = "default"      

    @revealSignal = false
    @selected = @defaultReport
    
    # default to displaying aggregate information for now
    @agg = true
    
    # order of radio buttons may change
    @randomRadio = Math.floor(Math.random() * 2)
    
    Network.setTaskController @
  
  slideToggleClicked: (ev) ->
    ev.preventDefault()
    $('div.task-chosenHouse').slideToggle()
        
  # called when this controller is activated in the stack
  active: (params)->
    super
    
    if Network.fakeServer
      Network.startExperiment()
    
    @render()
        
  render: ->
    return unless @isActive()
    
    @signalList   = Network.signalList
    @payAmounts   = Network.payAmounts    
    @numRounds    = Network.numRounds
    @numPlayers   = Network.numPlayers
    @currPlayerName = Network.currPlayerName
    
    @game   = Game.last()
    @games  = Game.all()
    
    @avgreward = @calcAvgReward()
    
    @html require('views/task')(@)

    @addDashedBorder()
    @randomizeRadioButtons()
    @scrollTableToBottom()

  scrollTableToBottom: ->
    # make the table always scroll to the bottom
    $('div .resultTableBody').scrollTop($('div .resultTableBody').prop("scrollHeight"))
    
  addDashedBorder: ->
    # add left and right dashed border style for the last row
    $('tr.borderAroundDashed td:first-child').addClass('borderLeftDashed')
    $('tr.borderAroundDashed td:last-child').addClass('borderRightDashed')

  randomizeRadioButtons: ->
    # random order of the radio buttons 
    if Network.signalList?
      if @randomRadio is 0
        $('input:radio#firstRadio').val("#{Network.signalList[0]}")
        $('img#imgFirstRadio').attr('src', "images/#{Network.signalList[0]}.png")
        $('input:radio#secondRadio').val("#{Network.signalList[1]}")
        $('img#imgSecondRadio').attr('src', "images/#{Network.signalList[1]}.png")      
      else
        $('input:radio#firstRadio').val("#{Network.signalList[1]}")
        $('img#imgFirstRadio').attr('src', "images/#{Network.signalList[1]}.png")
        $('input:radio#secondRadio').val("#{Network.signalList[0]}")
        $('img#imgSecondRadio').attr('src', "images/#{Network.signalList[0]}.png")

  calcAvgReward: ->
    totalReward = 0
    num = 0
    if @games
      for @eachgame in @games
        if @eachgame.result?[Network.currPlayerName]?.reward?
          totalReward = totalReward + @eachgame.result[Network.currPlayerName].reward
          num = num + 1
          
    if num > 0
      return Math.round(totalReward / num * 100)/100
    else
      return 0

  # called after getting the game state
  gotGameState: (gameState) ->
    Game.saveGame(gameState)

    # reset these for rendering
    @revealSignal = false 
    @selected = @defaultReport
    @reportChosen = false

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

    # set flag for rendering
    @reportChosen = true

    Network.sendReport(@selected)
    
    @render()
        
  helper: (msg) ->
    console.log msg
    
  # go to the exit survey
  goToExitSurvey: (e) ->
    e.preventDefault()
    @navigate '/exitsurvey'

module.exports = Task