Game        = require 'models/game'
TSClient    = require 'turkserver-js-client'
MockServer  = require 'mockserver'
Codec       = require 'turkserver-js-client/src/codec'

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
  
  @experimentStarted = false
    
  # @initFake: ->  
  #   @fakeServer = true

  @init: ->
    # @fakeServer = false
    TSClient.QuizRequired @quizNeeded
    TSClient.QuizFailed @quizFail
    TSClient.EnterLobby @enterLobby
    TSClient.ErrorMessage @rcvErrorMsg
    
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
    console.log "start experiment"
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
    console.log "received quiz failed message"
    alert "Sorry!  You failed the quiz.  We encourage you to try again.  If you'd like to quit, feel free to return this HIT."
    @mainCont.navigate '/quiz'
    @mainCont.quiz.render()
      
  @enterLobby: =>
    console.log "received enter lobby message"
    @mainCont.navigate '/lobby'

  @rcvErrorMsg: (status) =>
    console.log "error message received with status #{status}"
    msg = ""
    switch status
      when "status.toomanyfails"
        msg = "Sorry!  You have failed the quiz too many times.  You cannot work on this task anymore. Please return this HIT."
      when "status.killed"
        msg = "Sorry!  You disconnected from this task for too long.  You can no longer work on this task.  Please return this HIT."
      when "status.simultaneoussessions"
        msg = "It appears that you have already accepted another HIT for this game. Please return this HIT and submit your other HIT. Look for your other HIT in your dashboard."
      when "status.sessionoverlap"
        msg = "This HIT was returned by another worker who has already started playing the game, so it cannot be reused. Please return the HIT and accept another HIT from the group. "        
      when "status.toomanysessions"
        msg = "It appears that you have reached the limit for the number of HITs allowed for each worker.  Please return this HIT."
    
    console.log "msg = #{msg}"
    @mainCont.errormessage.setMessage msg
    @mainCont.navigate '/errormessage'
    @mainCont.errormessage.render()

  @getMessage: (msg) =>
    console.log "service message received: #{JSON.stringify(msg)}"
    switch msg.status
      when "startRound"
        @getGeneralInfo msg
      when "signal"
        @getSignal msg
      when "confirmReport"
        @getReportConfirmation msg
      when "results"
        @getGameResult msg
      when "killed"
        @rcvErrorMsg "status.killed"

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
    console.log "get signal #{JSON.stringify(receivedMsg)}"
    
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
    console.log "after get signal render"
    
    # get updates from the server
    if @fakeServer
      @intervalId = setInterval (=> 
        @getReportConfirmation MockServer.getConfirmReport()
      ), 3000
  
  @getGameResult: (receivedMsg) ->    
    console.log "get game result is #{JSON.stringify(receivedMsg)}"

    # save game result
    @game = Game.last()
    @game.result ?= {}
      
    for name in @playerNames
      @game.result[name] = {}
      @game.result[name].report     = receivedMsg.result[name].report
      theRefPlayer = receivedMsg.result[name].refPlayer
      @game.result[name].refPlayer  = theRefPlayer 
      @game.result[name].refReport  = receivedMsg.result[theRefPlayer].report
      @game.result[name].reward     = parseFloat(receivedMsg.result[name].reward)
    @game.save()

    
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

    # update ui
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
    @currPlayerReport = report
    
    if @fakeServer
      MockServer.sendReportToServer(report)
    else
      TSClient.sendExperimentService
        "report": report

  @getReportConfirmation: (receivedMsg) ->
    return unless receivedMsg
    
    console.log "confirmed report from #{receivedMsg.playerName}"

    # save confirmed report
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
    @currPlayerReport = undefined # reset curr player report after using it
    # console.log "current player name is #{@currPlayerName}"
    # console.log "current player report is #{@game.result[@currPlayerName]}"
 
    # update ui
    @task.render()

    # if we are using the mock server, check whether all other players have acted
    # if all other players have acted, get the result of the game
    if @fakeServer
      if @game.numOtherActed is (@numPlayers - 1) and @currConfirmed is true
        console.log "all players have reported."
        clearInterval(@intervalId)
      
        if @game.result?   # if the result array exists, then the player must have confirmed report already
          console.log "load the next game." 
          @getGameResult(MockServer.getResult())       

  @sendQuizInfo: (correct, total, checkedChoices) ->
    return unless not @fakeServer
    # send quiz answer to server
    TSClient.sendQuizResults correct, total, JSON.stringify(checkedChoices)

  @sendFinalInfo: (data) ->
    if @fakeServer
       # alert "exit survey answers: #{JSON.stringify(data)}"
    else
      TSClient.submitHIT JSON.stringify(data)

module.exports = Network