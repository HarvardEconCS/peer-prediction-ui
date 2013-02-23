Game        = require 'models/game'
TSClient    = require 'turkserver-js-client'
MockServer  = require 'mockserver'


class Network
  @cookieName = "peer.prediction.exp"
  
  @unconfirmMsg:  "questionmarkred"
  
  @fakeServer         = undefined
  @task               = undefined
  @mainCont           = undefined
  @intervalId         = null
  @currPlayerName     = undefined
  @currPlayerReport   = undefined
  @currConfirmed      = undefined

  @signalList      = undefined
  @payAmounts      = undefined
  @numPlayers      = undefined
  @numRounds       = undefined
  @playerNames     = undefined
  
  @showQuiz   = false
  @showLobby  = false
    
  @initFake: ->	
    @fakeServer = true

  @init: ->
    @fakeServer = false
    TSClient.QuizRequired @quizNeeded
    TSClient.QuizFailed @quizFail
    TSClient.EnterLobby @enterLobby
    
    TSClient.StartExperiment @startExperiment
    TSClient.StartRound (round) -> console.log("@StartRound" + round)
    TSClient.FinishExperiment -> console.log "@FinishExperiment"
    TSClient.ServiceMessage @getMessage 
    
    TSClient.init(@cookieName, "")
    
  @setTaskController: (taskCont) ->
    @task = taskCont

  @setMainController: (cont) ->
    @mainCont = cont

  @startExperiment: =>
    Game.init()    
    
    if not @fakeServer
      @mainCont.navigate '/task'
    else
      setTimeout (=> 
        @getGeneralInfo MockServer.getGeneralInfo() 
      ), 2000

  @quizNeeded: =>
    console.log "server asked for quiz"
    @showQuiz = true
    @mainCont.navigate '/'

  @quizFail: =>
    console.log "quiz failed"
    alert "Sorry!  You failed the quiz.  We encourage you to try again.  If you'd like to quit, feel free to return this HIT."
    @mainCont.navigate '/'
      
  @enterLobby: =>
    console.log "entering lobby"
    @mainCont.navigate '/lobby'

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

  @getGeneralInfo: (receivedMsg) ->  
    @signalList      = receivedMsg.signalList
    @payAmounts      = receivedMsg.payments
    @numPlayers      = receivedMsg.numPlayers
    @numRounds       = receivedMsg.numRounds 
    @playerNames     = receivedMsg.playerNames
    @currPlayerName  = receivedMsg.yourName
    @numPlayed = 0
        
    # if there are only 2 players, no point to aggregate the info
    @task.agg = false if @numPlayers is 2
    @task.render()

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
    return unless receivedMsg
    
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

  @sendQuizInfo: (correct, total) ->
    return unless not @fakeServer
    # send quiz answer to server
    TSClient.sendQuizResults correct, total  

  @sendFinalInfo: (data) ->
    if @fakeServer
      alert "exit survey answers: #{JSON.stringify(data)}"
    else
      TSClient.submitHIT(data)

module.exports = Network