
class MockServer
  
  @signalH =    "MM"
  @signalL =    "GM"
  @signalList = [@signalH, @signalL]
  @jarInfo =    [10, 3, 4]
  
  @nPlayers = 5
  @playerNames = []
  @results = []

  @chooseRandomly: (list) ->
    i = Math.floor(Math.random() * list.length)
    list[i]  
  
  @getGeneralInfo: (currName) -> 
    # Need to know which player is it sending the message to
  
    # Message received from server
    # format: --------------------
    #       status:     startRound
    #       numPlayers: 
    #       playerNames: 
    #       yourName: 
    #       numRounds: 
    #       payments:
    # -------------------------
    for i in [0..(@nPlayers - 1)]
      @playerNames.push "Player #{i}"
    
    rndIndex = Math.floor(Math.random() * @playerNames.length)
    currName = @playerNames[rndIndex]
    
    receivedMsg = 
      "status"      : "startRound"
      "numPlayers"  : @nPlayers
      "numRounds"   : 3
      "playerNames" : @playerNames
      "yourName"    : currName 
      "payments"  : [0.58, 0.36, 0.43, 0.54]
    
  @getRoundSignal: ->
    # Message received from server
    # format: -----------------
    #     status: signal
    #     signal: 
    # -------------------------
    nextSignal = @chooseRandomly(@signalList)
    
    receivedMsg = 
      "status:" : "signal"
      "signal"  : nextSignal 
    
  @getResult: ->
    # Message received from server
    # format: --------------
    #     status: results
    #     result: 
    # ----------------------
    receivedMsg = 
      "status": "results"
      "result": {}
      
    # We should have the reports already
    for name in @playerNames
      receivedMsg.result[name] = {}
      receivedMsg.result[name].report = @chooseRandomly(@signalList)
      
    # this is getting the reference players
    for name, i in @playerNames
      refIndex = Math.floor(Math.random() * (@nPlayers - 1))
      if i <= refIndex
        refIndex = refIndex  + 1
      receivedMsg.result[name].refPlayer = @playerNames[refIndex]

    for name in @playerNames
      theReport     = receivedMsg.result[name].report
      theRefPlayer  = receivedMsg.result[name].refPlayer
      theRefReport  = receivedMsg.result[theRefPlayer].report
      receivedMsg.result[name].reward     = Network.getPayment(theReport, theRefReport)
      
    receivedMsg
  
  @getConfirmReport: ->
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

  @getPayment: (report, refReport) ->
    left = Network.signalList.indexOf(report)
    right = Network.signalList.indexOf(refReport)
    index = left * 2 + right
    return Network.payAmounts[index]    
  
module.exports = MockServer