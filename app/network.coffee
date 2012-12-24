Game    = require 'models/game'
TSClient = require 'turkserver-js-client'
MockServer = require 'mockserver'

class Network
  @cookieName = "peer.prediction.exp"
  
  @unconfirmMsg:  "questionmarkred"
  
  @fakeServer         = undefined
  @task               = undefined
  @intervalId         = null
  @currPlayerName     = undefined
  @currPlayerReport   = undefined
  @currConfirmed      = undefined

  @signalList      = undefined
  @payAmounts      = undefined
  @numPlayers      = undefined
  @numRounds       = undefined
  @playerNames     = undefined
  
  # Initialize fake server
  @initFake: ->	
    @fakeServer = true

  # Initialize real server
  @init: ->
    @fakeServer = false
    TSClient.StartExperiment -> console.log "@StartExperiment"
    TSClient.StartRound (round) -> console.log("@StartRound" + round)
    TSClient.FinishExperiment -> console.log "@FinishExperiment"
    TSClient.ServiceMessage @getMessage 

  # Configure task controller
  @setTaskController: (taskCont) ->
    @task = taskCont

  @ready: ->
    if @fakeServer
      Game.init()
      setTimeout (=> 
        @getGeneralInfo MockServer.getGeneralInfo() 
      ), 2000
      
    else
      Game.init();
      TSClient.init(@cookieName, "")

  @getMessage: (msg) =>
    console.log msg
    switch msg.status
      when "startRound"
        @getGeneralInfo msg
      when "signal"
        @getSignal msg
      when "confirmReport"
        @getReportConfirmation msg
      when "results"
        @getGameResult msg


    
  # start the first game    
  @getGeneralInfo: (receivedMsg) ->  
    @signalList      = receivedMsg.signalList
    @payAmounts      = receivedMsg.payments
    @numPlayers      = receivedMsg.numPlayers
    @numRounds       = receivedMsg.numRounds 
    @playerNames     = receivedMsg.playerNames
    @currPlayerName  = receivedMsg.yourName
    @numPlayed   = 0
        
    # if there are only 2 players, no point to aggregate the information
    if @numPlayers is 2
      @task.agg = false

    @task.render()

    # get information for the next game
    if @fakeServer
      setTimeout (=> 
        @getSignal MockServer.getRoundSignal()
      ), 100


  @getSignal: (receivedMsg) ->    
    # reset variables
    @currConfirmed    = false
    @currPlayerReport = null
    
    reportConfirmed = {}
    for name in @playerNames
      reportConfirmed[name] = false
    
    gameState =
      "numPlayed":        @numPlayed
      "signal":           receivedMsg.signal 
      "numOtherActed":    0
      "reportConfirmed":  reportConfirmed
    
    # update interface
    @task.gotGameState(gameState)
    @task.render()
    
    # get updates from the server
    if @fakeServer
      @intervalId = setInterval (=> 
        @getReportConfirmation MockServer.getConfirmReport()
      ), 3000
  
  # get next game
  @getGameResult: (receivedMsg) ->    
    console.log "get game result is #{JSON.stringify(receivedMsg)}"

    @game = Game.last()
    if @game.result?
    else
      @game.result = {}
    
    for name in @playerNames
      @game.result[name] = {}

      @game.result[name].report     = receivedMsg.result[name].report
      
      theRefPlayer = receivedMsg.result[name].refPlayer
      @game.result[name].refPlayer  = theRefPlayer 
      @game.result[name].refReport  = receivedMsg.result[theRefPlayer].report
      @game.result[name].reward     = receivedMsg.result[name].reward
    @game.save()
    console.log "game with result is #{@game}"
    
    # count number of people who reported signalList[0]
    count = 0
    if @game.result?
      for name in @playerNames
        if name is @currPlayerName
          continue
        else
          if receivedMsg.result[name].report is @signalList[0]
            count = count + 1
    @game.numSignal0 = count
    @game.save()

    @task.render()

    # Check if we are finished with all games
    @numPlayed += 1
    if @numPlayed is @numRounds
      @task.finish()
      return
    
    # get information for the next game
    if @fakeServer
      setTimeout( => @getSignal MockServer.getRoundSignal(), 100 )    
    
    
  @sendReport: (report) ->
    if @fakeServer
      @currPlayerReport = report
      MockServer.sendReportToServer(report)
    else
      TSClient.sendExperimentService
        "report": report

  @getReportConfirmation: (receivedMsg) ->
    if receivedMsg is null
      return
    
    console.log "update actions: receivedMsg is #{JSON.stringify(receivedMsg)}"

    @game = Game.last()
    
    @game.reportConfirmed[receivedMsg.playerName] = true
    if receivedMsg.playerName is @currPlayerName
      if @game.result?
        if @game.result[@currPlayerName]?
          @game.result[@currPlayerName].report = @currPlayerReport
        else
          @game.result[@currPlayerName] = {"report": @currPlayerReport}
      else
        @game.result = {}
        @game.result[@currPlayerName] = {"report": @currPlayerReport}
      @currConfirmed = true
    else
      @game.numOtherActed += 1
    @game.save()
 
    @task.render()

    # check if other players have acted
    if @game.numOtherActed is (@numPlayers - 1) and @currConfirmed is true
      console.log "all players have reported."
      clearInterval(@intervalId)
      
      if @game.result?   # if the result array exists, then the player must have confirmed report already
        console.log "load the next game."
        @getGameResult(MockServer.getResult())    


  @sendQuizAns: (ans) ->
    # send quiz answer to server

module.exports = Network