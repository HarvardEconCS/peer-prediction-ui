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

  @showTutorial = false
  @showRecap = false
  @showLobby  = false

  @experimentStarted = false

  @payRandList = undefined

  @init: ->
    TSClient.QuizRequired @quizNeeded
    TSClient.QuizFailed   @quizFail
    TSClient.EnterLobby   @enterLobby
    TSClient.ErrorMessage @rcvErrorMsg

    TSClient.LobbyMessage @getLobbyUpdates

    TSClient.StartExperiment  @startExperiment
    TSClient.StartRound (round) -> console.log("@StartRound" + round)
    TSClient.FinishExperiment @finishExperiment
    TSClient.ServiceMessage   @getMessage

    TSClient.init(@cookieName, "")

  @randomizePayList: ->
    # @payRandList = @randomizeList(4)
    @payRandList = [@randomizeCol(), @randomizeRow()]

  @randomizeCol: ->
    rand = Math.floor(Math.random() * 2)
    if rand is 0
      return [0,1]
    else
      return [1,0]

  @randomizeRow: ->
    rand = Math.floor(Math.random() * 2)
    if rand is 0
      return [0,1,2,3]
    else
      return [3,2,1,0]

  @randomizeList: (len) ->
    oldList = (num for num in [0..(len-1)])
    num = len
    newList = []

    while num > 0
      rand = Math.floor(Math.random() * num)
      newList.push(oldList[rand])
      oldList.splice(rand, 1)
      num = num - 1

    newList

  @setTaskController: (cont) ->
    @taskCont = cont

  @setMainController: (cont) ->
    @mainCont = cont

  @getClientId: ->
    TSClient.clientId

  @getLobbyUpdates: (data) =>
    return unless data.status is 'update'    # if we see a ready = true message, ignores it
    @mainCont.lobby.updateInfo data

  @quizNeeded: (quizType) =>
    # Do different stuff depending on type of quiz
    console.log "@QuizRequired"
    if quizType is "tutorial"
      @showTutorial = true
    else if quizType is "recap"
      @showRecap = true
    @mainCont.navigate '/'

  @quizFail: =>
    console.log "@QuizFailed"
    @mainCont.quiz.showQuizFailedMsg()

  @enterLobby: =>
    console.log "@EnterLobby"
    @showLobby = true
    @mainCont.navigate '/lobby'

  @updateLobbyStatus: (status) ->
    TSClient.updateLobbyStatus status

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
    console.log "@ErrorMessageStatus:#{status}"
    msg = ""
    switch status
      when Codec.status_failsauce
        msg = "Sorry!  You have failed the quiz 3 times.
                       You cannot work on our HITs anymore. Please return this HIT."
      when "status.killed"
        msg = "Sorry!  You disconnected from this HIT for too long.
                       You cannot work on this HIT anymore.  Please return this HIT."
      when Codec.status_simultaneoussessions
        msg = "It appears that you have already accepted another HIT for this game.
                       Please return this HIT and submit your other HIT.
                       Look for your other HIT in your dashboard."
      when Codec.status_sessionoverlap
        msg = "This HIT was returned by another worker who has already started playing the game,
                       so it cannot be reused. Please return the HIT and accept another HIT from the group. "
      when Codec.status_toomanysessions
        msg = "You can do at most 1 of our HITs.  It appears that you have reached this limit.
                       Please return this HIT."
      when Codec.status_expfinished
        @mainCont.navigate '/exitsurvey'
        return
      when Codec.status_batchfinished
        msg = "All games for this batch have been completed.
                       We will notify you if we post more HITs in the future.
                       Please return this HIT."
    @mainCont.errormessage.setMessage msg
    @mainCont.navigate '/errormessage'
    @mainCont.errormessage.render()

  @getMessage: (msg) =>
    console.log "@ServiceMessage:#{JSON.stringify(msg)}"
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
    console.log "@ReconnectWithState:#{JSON.stringify(receivedMsg)}"
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
    return unless receivedMsg

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
    return unless receivedMsg

    # save game result
    @game = Game.last()
    @game.result ?= {}
    for name in @playerNames
      @game.result[name] ?= {}
      @game.result[name].report     = receivedMsg.result[name].report
      # theRefPlayer = receivedMsg.result[name].refPlayer
      # @game.result[name].refPlayer  = theRefPlayer
      # @game.result[name].refReport  = receivedMsg.result[theRefPlayer].report
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