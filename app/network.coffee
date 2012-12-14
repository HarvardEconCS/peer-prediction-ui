Game    = require 'models/game'

class Network
  
  @signalH:     "MM"
  @signalL:     "GM"
  @signalList:  [@signalH, @signalL]
  @jarInfo:     [10, 3, 4]
  # @defaultOption: "default"
  @unconfirmMsg:  "questionmarkred"
  
  @fakeServer: true
  @task: null
  
  @intervalId: null
  # @currPlayer: null
  @currPlayerName: null
  
  @currPlayerReport: null
  @currPlayerReportConfirmed: false
  
  @finished: false
  
  # Initialize fake server
  @initFake: ->	
    # Network.currPlayer = 'turkId3'

  # Initialize real server
  @init: ->
    Network.fakeServer = false

  # Configure task controller
  @setTaskController: (taskController) ->
    Network.task = taskController

  @ready: ->
    if Network.fakeServer
      console.log "Network.ready:"
      Game.init()
      setTimeout Network.getGeneralInfo, 2000
    else

  # repeated called to get action updates from server
  @updateActions: ->


    ###############################################
    @game = Game.last()
    playerNotConfirmed = []
    for name in Object.keys(@game.reportConfirmed)
      if name is Network.currPlayerName and Network.currPlayerReport is null
      else 
        if @game.reportConfirmed[name] is false
          playerNotConfirmed.push name
    if playerNotConfirmed.length is 0
      return
    ###############################################

    ################################################
    # Message received from the server
    # format: -------------------
    #    status: confirmReport
    #    playerName: 
    # ---------------------------
    randomIndex = Math.floor(Math.random() * playerNotConfirmed.length)
    playerActed = playerNotConfirmed[randomIndex]

    # get new status from server
    receivedMsg = 
      "status"      : "confirmReport"
      "playerName"  : playerActed 
    ##############################################
    console.log "server confirmed report by #{receivedMsg.playerName}"

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
      console.log "all players have acted, stop getting action updates."
      clearInterval(Network.intervalId)
      
      if @game.result?   # if the result array exists, then the player must have confirmed report already
        console.log "load the next game."
        Network.getGameResult()
    
    
  # start the first game    
  @getGeneralInfo: ->

    ####################################################
    # Message received from server
    # format: --------------------
    #       status:     startRound
    #       numPlayers: 
    #       playerNames: 
    #       yourName: 
    #       numRounds: 
    #       payments:
    # -------------------------
    nPlayers = 5
    
    names = []
    for i in [0..(nPlayers - 1)]
      names.push "Player #{i}"
    
    rndIndex = Math.floor(Math.random() * names .length)
    currName = names[rndIndex]
    
    receivedMsg = 
      "status"      : "startRound"
      "numPlayers"  : nPlayers
      "playerNames" : names
      "yourName"    : currName 
      "numRounds"   : 10
      "payments"  : [0.58, 0.36, 0.43, 0.54]
    ####################################################
    console.log "received msg: #{JSON.stringify(receivedMsg)}"
      
    # save metadata
    Network.payAmounts      = receivedMsg.payments
    Network.numPlayers      = receivedMsg.numPlayers
    Network.numRounds       = receivedMsg.numRounds 
    Network.playerNames     = receivedMsg.playerNames
    Network.currPlayerName  = receivedMsg.yourName
    console.log "curr player name is #{Network.currPlayerName}"  
        
    # if there are only 2 players, no point to aggregate the information
    if Network.numPlayers is 2
      Network.task.agg = false
      
    Network.numPlayed   = 0

    # get information for the next game
    Network.getNextGameInfo()

  @getNextGameInfo: ->

    ####################################################
    # Message received from server
    # format: -----------------
    #     status: signal
    #     signal: 
    # -------------------------
    nextSignal = Network.chooseRandomly(Network.signalList)
    
    receivedMsg = 
      "status:" : "signal"
      "signal"  : nextSignal 
    ####################################################
    
    Network.currPlayerReportConfirmed = false
    Network.currPlayerReport = null
    
    reportConfirmed = {}
    for name, i in Network.playerNames
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
    Network.intervalId = setInterval Network.updateActions, 5000
    
    
    
  # get next game
  @getGameResult: ->    
    
    ##########################################
    # Message received from server
    # format: --------------
    #     status: results
    #     result: 
    # ----------------------
    receivedMsg = 
      "status": "results"
      "result": {}
    for name in Network.playerNames
      receivedMsg.result[name] = {}
      if name is Network.currPlayerName
        receivedMsg.result[name].report = Network.currPlayerReport
      else
        receivedMsg.result[name].report = Network.chooseRandomly(Network.signalList)
    for name, i in Network.playerNames
      refIndex = Math.floor(Math.random() * (Network.numPlayers - 1))
      if i <= refIndex
        refIndex = refIndex  + 1
      receivedMsg.result[name].refPlayer = Network.playerNames[refIndex]
    ##########################################
    # console.log "result object: #{JSON.stringify(receivedMsg)}"

    @game = Game.last()
    if @game.result?
    else
      @game.result = {}
    
    for name in Network.playerNames
      @game.result[name] = {}
      
      theReport     = receivedMsg.result[name].report
      theRefPlayer  = receivedMsg.result[name].refPlayer
      theRefReport  = receivedMsg.result[theRefPlayer].report
      
      @game.result[name].report     = theReport
      @game.result[name].refPlayer  = theRefPlayer
      @game.result[name].refReport  = theRefReport
      @game.result[name].reward     = Network.getPayment(theReport, theRefReport)
    @game.save()
    
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
    Network.getNextGameInfo()
    

  @sendReport: (report) ->
    Network.currPlayerReport = report


  @chooseRandomly: (list) ->
    i = Math.floor(Math.random() * list.length)
    list[i]

  @getPayment: (report, refReport) ->
    left = Network.signalList.indexOf(report)
    right = Network.signalList.indexOf(refReport)
    index = left * 2 + right
    return Network.payAmounts[index]

module.exports = Network