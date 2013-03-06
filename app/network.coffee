Game        = require 'models/game'
TSClient    = require 'turkserver-js-client'
MockServer  = require 'mockserver'
Codec       = require 'turkserver-js-client/src/codec'

class Network
  @cookieName = "peer.prediction.exp"
  
  @unconfirmMsg:  "questionmarkred"
  
  @fakeServer      = undefined
  @intervalId      = null
  
  @taskCont        = undefined
  @mainCont        = undefined

  @currPlayerName  = undefined

  @signalList      = undefined
  @payAmounts      = undefined
  @numPlayers      = undefined
  @numRounds       = undefined
  @playerNames     = undefined
  
  @showQuiz   = false
  @showLobby  = false
  
  @experimentStarted = false

  @init: ->
    TSClient.QuizRequired @quizNeeded
    TSClient.QuizFailed   @quizFail
    TSClient.EnterLobby   @enterLobby
    TSClient.ErrorMessage @rcvErrorMsg
    
    TSClient.StartExperiment  @startExperiment
    TSClient.StartRound (round) -> console.log("@StartRound" + round)
    TSClient.FinishExperiment @finishExperiment
    TSClient.ServiceMessage   @getMessage 
    
    TSClient.init(@cookieName, "")
    
  @setTaskController: (cont) ->
    @taskCont = cont

  @setMainController: (cont) ->
    @mainCont = cont

  @quizNeeded: =>
    console.log "quiz required"
    @showQuiz = true
    @mainCont.navigate '/'

  @quizFail: =>
    console.log "quiz failed"
    alert "Sorry!  You failed the quiz.  We encourage you to try again.  If you'd like to quit, feel free to return this HIT."
    @mainCont.navigate '/quiz'
    @mainCont.quiz.render()
      
  @enterLobby: =>
    console.log "enter lobby"
    @mainCont.navigate '/lobby'

  @startExperiment: =>
    console.log "@StartExperiment"
    Game.init()    
    
    if not @fakeServer
      @mainCont.navigate '/task'
    else
      setTimeout (=> 
        @getGeneralInfo MockServer.getGeneralInfo() 
      ), 2000

  @finishExperiment: =>
    console.log "@FinishExperiment"
    
    @taskCont.finish()

  @rcvErrorMsg: (status) =>
    console.log "error message received with status #{status}"
    msg = ""
    switch status
      when Codec.status_failsauce
        msg = "Sorry!  You have failed the quiz too many times.  
               You cannot work on this task anymore. Please return this HIT."
      when "status.killed"
        msg = "Sorry!  You disconnected from this task for too long.  
               You can no longer work on this task.  Please return this HIT."
      when Codec.status_simultaneoussessions
        msg = "It appears that you have already accepted another HIT for this game. 
               Please return this HIT and submit your other HIT. 
               Look for your other HIT in your dashboard."
      when Codec.status_sessionoverlap
        msg = "This HIT was returned by another worker who has already started playing the game, 
               so it cannot be reused. Please return the HIT and accept another HIT from the group. "        
      when Codec.status_toomanysessions
        msg = "It appears that you have reached the limit for the number of HITs allowed for each worker.  
               Please return this HIT."
      when Codec.status_completed
        @mainCont.navigate '/exitsurvey'
        return
    @mainCont.errormessage.setMessage msg
    @mainCont.navigate '/errormessage'
    @mainCont.errormessage.render()

  @getMessage: (msg) =>
    console.log "service message received: #{JSON.stringify(msg)}"
    switch msg.status
      when "generalInfo"
        @getGeneralInfo msg
      when "signal"
        @getSignal msg
      when "confirmReport"
        @getReportConfirmation msg
      when "results"
        @getGameResult msg
      when "resendState"
        @getResendState msg
      when "loadExitSurvey"
        @mainCont.navigate '/exitsurvey'
      when "killed"
        @rcvErrorMsg "status.killed"
  
  @getResendState: (receivedMsg) ->
    console.log "process resend state #{JSON.stringify(receivedMsg)}"
    return if @numPlayers?
    
    
    
    @signalList      = receivedMsg.signalList
    @payAmounts      = receivedMsg.payments
    @numPlayers      = receivedMsg.numPlayers
    @numRounds       = receivedMsg.numRounds 
    @playerNames     = receivedMsg.playerNames
    @currPlayerName  = receivedMsg.yourName
    
    for res in receivedMsg.existingResults
      resultObj = {}
      for name in @playerNames
        resultObj[name] = {'report' : res[name].report}
        if name is @currPlayerName
          resultObj[name].reward = parseFloat(res[name].reward)
      signalZeroCount = 0 
      for name in @playerNames
        if name isnt @currPlayerName and res[name].report is @signalList[0]
          signalZeroCount = signalZeroCount + 1
      gameState = 
        'result'          : resultObj
        'currPlayerSignal': res[@currPlayerName].signal
        'numSignalZero'   : signalZeroCount 
      Game.saveGame(gameState)  


    # save information of last game
    currReportConfirmed = receivedMsg.workersConfirmed.indexOf(@currPlayerName) >= 0

    numOtherReportsConfirmed = receivedMsg.workersConfirmed.length
    if currReportConfirmed is true
      numOtherReportsConfirmed = numOtherReportsConfirmed - 1
      
    reportsConfirmed = {}
    for name in @playerNames
      if receivedMsg.workersConfirmed.indexOf(name) >= 0
        reportsConfirmed[name] = true
      else
        reportsConfirmed[name] = false

    if currReportConfirmed is true
      @taskCont.revealSignal = true
      @taskCont.reportChosen = true
      @taskCont.selected = receivedMsg.currPlayerReport

    resultObj = {}
    if currReportConfirmed is true
      resultObj[@currPlayerName] = {'report' : receivedMsg.currPlayerReport}
     
    lastGame = 
      'reportConfirmed'  : reportsConfirmed
      'result'           : resultObj 
      'currPlayerSignal' : receivedMsg.currPlayerSignal
      'numOtherReportsConfirmed' : numOtherReportsConfirmed 
    Game.saveGame(lastGame)
    
    # update ui
    @mainCont.navigate '/task'
    @taskCont.render()

      

  @getGeneralInfo: (receivedMsg) ->  
    @signalList      = receivedMsg.signalList
    @payAmounts      = receivedMsg.payments
    @numPlayers      = receivedMsg.numPlayers
    @numRounds       = receivedMsg.numRounds 
    @playerNames     = receivedMsg.playerNames
    @currPlayerName  = receivedMsg.yourName
    
    # update ui
    @taskCont.render()

    # mockserver: get signal for the first round
    if @fakeServer
      setTimeout (=> 
        @getSignal MockServer.getRoundSignal()
      ), 100

  @getSignal: (receivedMsg) ->    
    return unless receivedMsg
    
    # save new game
    reportConfirmed = {}
    for name in @playerNames
      reportConfirmed[name] = false 
    gameState =
      "reportConfirmed":          reportConfirmed
      "currPlayerSignal":         receivedMsg.signal 
      "numOtherReportsConfirmed": 0
    @taskCont.gotGameState(gameState)

    # mockserver: set up call back for report confirmations
    if @fakeServer
      @intervalId = setInterval (=> 
        @getReportConfirmation MockServer.getConfirmReport()
      ), 3000
  
  @getReportConfirmation: (receivedMsg) ->
    return unless receivedMsg

    # save confirmed report
    @game = Game.last()
    @game.reportConfirmed[receivedMsg.playerName] = true
    if receivedMsg.playerName is @currPlayerName
      @game.result ?= {}
      @game.result[@currPlayerName] ?= {"report": @game.currPlayerReport}
      @game.result[@currPlayerName].report = @game.currPlayerReport
    else
      @game.numOtherReportsConfirmed += 1
    @game.save()
 
    # update ui
    @taskCont.render()

    # mockserver: if all reports are confirmed, load next game
    if @fakeServer
      @game = Game.last()
      if @game.numOtherReportsConfirmed is (@numPlayers - 1) and @game.currPlayerReport?
        clearInterval(@intervalId)
        @getGameResult(MockServer.getResult())        
  
  @getGameResult: (receivedMsg) ->    
    # console.log "get game result is #{JSON.stringify(receivedMsg)}"

    # save game result
    @game = Game.last()
    @game.result ?= {}
    for name in @playerNames
      @game.result[name] ?= {}
      @game.result[name].report     = receivedMsg.result[name].report
      theRefPlayer = receivedMsg.result[name].refPlayer
      @game.result[name].refPlayer  = theRefPlayer 
      @game.result[name].refReport  = receivedMsg.result[theRefPlayer].report
      @game.result[name].reward     = parseFloat(receivedMsg.result[name].reward)
    signalZeroCount = 0 # count number of people who reported signalList[0]
    for name in @playerNames
      if name isnt @currPlayerName and receivedMsg.result[name].report is @signalList[0]
        signalZeroCount = signalZeroCount + 1
    @game.numSignalZero = signalZeroCount
    @game.save()

    # update ui
    @taskCont.render()

    # mockserver: if all games are finished, update ui, otherwise, get signal for next game
    if @fakeServer
      if Game.all().length is @numRounds
        # update ui if all games are finished
        @taskCont.finish()
      else
        # get signal for next game
        setTimeout( => @getSignal MockServer.getRoundSignal(), 100 )    
    
  @sendReport: (report) ->
    @game = Game.last()
    @game.currPlayerReport = report if @game
    @game.save()
    
    if not @fakeServer
      TSClient.sendExperimentService
        "report": report
    else 
      MockServer.sendReportToServer(report)
 
  @sendQuizInfo: (correct, total, checkedChoices) ->
    return if @fakeServer is true

    TSClient.sendQuizResults correct, total, JSON.stringify(checkedChoices)

  @sendHITSubmitInfo: (data) ->
    return if @fakeServer is true

    TSClient.submitHIT JSON.stringify(data)

module.exports = Network