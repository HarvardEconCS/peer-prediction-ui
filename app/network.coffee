Game    = require 'models/game'
TSClient = require 'turkserver-js-client'

class Network
  @cookieName = "peer.prediction.exp"
  
  @unconfirmMsg:  "questionmarkred"
  
  @fakeServer   = undefined
  @task         = undefined
  @intervalId   = null
  @currPlayerName     = null
  @currPlayerReport   = null
  @currPlayerReportConfirmed = false
  
  @signalList      = undefined
  @payAmounts      = undefined
  @numPlayers      = undefined
  @numRounds       = undefined
  @playerNames     = undefined
  @currPlayerName  = undefined
  
  # Initialize fake server
  @initFake: ->	
    # @currPlayerName = 'turkId3'

  # Initialize real server
  @init: ->
    @fakeServer = false
    TSClient.StartExperiment -> console.log "@StartExperiment"
    TSClient.StartRound (round) -> console.log("@StartRound" + round)
    TSClient.FinishExperiment -> console.log "@FinishExperiment"
    TSClient.ServiceMessage @getMessage 

  # Configure task controller
  @setTaskController: (taskController) ->
    Network.task = taskController

  @ready: ->
    if @fakeServer
      console.log "Network.ready:"
      Game.init()
      setTimeout(( => @getGeneralInfo(MockServer.getGeneralInfo "player 1")), 2000)
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
        @updateActions msg
      when "results"
        @getGameResult msg


    
  # start the first game    
  @getGeneralInfo: (receivedMsg) ->  
    # console.log "got general info: #{JSON.stringify(receivedMsg)}"    
    
    Network.signalList      = receivedMsg.signalList
    Network.payAmounts      = receivedMsg.payments
    Network.numPlayers      = receivedMsg.numPlayers
    Network.numRounds       = receivedMsg.numRounds 
    Network.playerNames     = receivedMsg.playerNames
    Network.currPlayerName  = receivedMsg.yourName
        
    # if there are only 2 players, no point to aggregate the information
    if Network.numPlayers is 2
      Network.task.agg = false
      
    Network.numPlayed   = 0

    @task.render()

    # get information for the next game
    if @fakeServer
      setTimeout( => @getSignal MockServer.getRoundSignal(), 100 )



  @getSignal: (receivedMsg) ->    
    # console.log "got signal: #{JSON.stringify(receivedMsg)}"
    
    Network.currPlayerReportConfirmed = false
    Network.currPlayerReport = null
    
    reportConfirmed = {}
    for name in Network.playerNames
      reportConfirmed[name] = false
    
    gameState =
      "numPlayed":        Network.numPlayed
      "signal":           receivedMsg.signal 
      "numOtherActed":    0
      "reportConfirmed":  reportConfirmed
    
    # update interface
    Network.task.gotGameState(gameState)
    Network.task.render()
    
    # get updates from the server
    if @fakeServer
      Network.intervalId = 
        setInterval Network.updateActions(MockServer.getConfirmReport()), 5000        
    
  
  # get next game
  @getGameResult: (receivedMsg) ->    
    # console.log "got result: #{JSON.stringify(receivedMsg)}"

    @game = Game.last()
    if @game.result?
    else
      @game.result = {}
    
    for name in Network.playerNames
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
      for name in Network.playerNames
        if name is Network.currPlayerName
          continue
        else
          if receivedMsg.result[name].report is Network.signalList[0]
            count = count + 1
    @game.numSignal0 = count
    @game.save()

    Network.task.render()

    # Check if we are finished with all games
    Network.numPlayed += 1
    if Network.numPlayed is Network.numRounds
      Network.task.finish()
      return
    
    # get information for the next game
    if @fakeServer
      setTimeout( => @getSignal MockServer.getRoundSignal(), 100 )    
    
    
    
    
  @sendReport: (report) ->
    if @fakeServer
      Network.currPlayerReport = report
    else
      TSClient.sendExperimentService
        "report": report



  # repeated called to get action updates from server
  @updateActions: (receivedMsg) ->
    # console.log "server confirmed report by #{receivedMsg.playerName}"

    @game = Game.last()
    
    @game.reportConfirmed[receivedMsg.playerName] = true
    if receivedMsg.playerName is Network.currPlayerName
      if @game.result?
        if @game.result[Network.currPlayerName]?
          @game.result[Network.currPlayerName].report = Network.currPlayerReport
        else
          @game.result[Network.currPlayerName] = {"report": Network.currPlayerReport}
      else
        @game.result = {}
        @game.result[Network.currPlayerName] = {"report": Network.currPlayerReport}
      Network.currPlayerReportConfirmed = true
    else
      @game.numOtherActed += 1
    @game.save()
    
    Network.task.render()

    # check if other players have acted
    if @game.numOtherActed is (Network.numPlayers - 1) and Network.currPlayerReportConfirmed is true
      console.log "all players have reported."
      clearInterval(Network.intervalId)
      
      if @game.result?   # if the result array exists, then the player must have confirmed report already
        console.log "load the next game."
        Network.getGameResult()    


module.exports = Network