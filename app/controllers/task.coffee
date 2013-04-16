Spine = require('spine')

Network = require 'network'
Game    = require 'models/game'

class Task extends Spine.Controller
  className: "task"

  elements: 
    "div#taskErrorMsg" : "taskErrorMsg"

  events:
    'change input:radio:checked' : 'radioChanged'    
    'click .getsignal': 'revealSignalFunc'  # button to reveal signal
    'click .confirm'  : 'confirmReport'     # button to confirm report
    'click .exit'     : 'goToExitSurvey'    # button to go to exit survey 
    "click a#returnToTask" : "returnToTaskClicked"

  constructor: ->
    super
    @revealSignal   = false    
    @defaultReport  = "default"      
    @selected       = @defaultReport
    @randomRadio    = Math.floor(Math.random() * 2)
    @bonus          = 0
    @errorShown = false
    
    Network.setTaskController @

  active: (params)->
    super    
    @render()
        
  render: ->
    return unless @isActive()

    if Network.fakeServer and Network.experimentStarted is false
      Network.startExperiment()
      Network.experimentStarted = true

    @games  = Game.all()
    @game   = Game.last()
    @bonus  = @calcAvgReward()
    
    @html require('views/task')(@)

    # randomize order of rows in reward rule table
    @randomizeRuleTable('task-ruleTable')

    @addDashedBorder()
    @randomizeRadioButtons()
    @scrollTableToBottom()
    
    if @errorShown
      @taskErrorMsg.show()
    else
      @taskErrorMsg.hide()

  randomizeRuleTable: (divId) ->
    trList = []
    tbody= $('div#' + divId).find('tbody')
    if tbody.length is 0
      return
    firstRow = tbody.children()[0]
    len = tbody.children().length
    for num in [1..len]
      trList.push tbody.children()[num]
      
    if Network.payRandList is undefined
      Network.randomizePayList()
      
    newTrList = []
    for index in Network.payRandList
      newTrList.push(trList[index])
    
    tbody.contents().remove()
    tbody.append(firstRow)
    for tr in newTrList
      tbody.append(tr)
      
  scrollTableToBottom: ->
    # make the table always scroll to the bottom
    $('div #result-body').scrollTop($('div #result-body').prop("scrollHeight"))
    
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
      @bonus =  Math.round(totalReward / num * 100) / 100
    else
      @bonus = 0

  # called after getting the game state
  gotGameState: (gameState) ->
    Game.saveGame(gameState)

    # reset these for rendering
    @revealSignal = false 
    @selected     = @defaultReport
    @reportChosen = false
    @randomRadio = Math.floor(Math.random() * 2)

    @render()
    
  # called when all games are finished
  finish: ->
    @finished = true
    @render()
    
    # game is finished, remove the dashed border around the last game
    $('tr').removeClass("borderAroundDashed")
    $('td').removeClass("borderLeftDashed")
    $('td').removeClass("borderRightDashed")

  revealSignalFunc: (e) =>
    e.preventDefault()
    @revealSignal = true
    @render()

	# selected report is changed
  radioChanged: =>
    @selected = $('input:radio:checked').val()

  returnToTaskClicked: (ev) =>
    ev.preventDefault()
    @errorShown = false
    @taskErrorMsg.hide()

  # player confirms report
  confirmReport: (e) =>
    e.preventDefault()
    
    # if the player hasn't revealed the candy yet, 
    # since the choose claim button is not displayed before revealing candy,
    # we don't need to check for this anymore.
    # 
    # if @revealSignal is false
    #   alert("Please get a candy first before choosing your report!")
    #   @selected = @defaultReport # reset selected report
    #   @render()
    #   return
    
    # the player hasn't selected a report yet
    if @selected is @defaultReport
      @errorShown = true
      @taskErrorMsg.show()
      return

    Network.sendReport(@selected)

    # set flag for rendering
    @reportChosen = true    
    @render()
        
  # go to the exit survey
  goToExitSurvey: (e) =>
    e.preventDefault()
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
    @navigate '/exitsurvey'

module.exports = Task