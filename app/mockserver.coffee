Game    = require 'models/game'

class MockServer
  
  @signalH    = "MM"
  @signalL    = "GB"
  @signalList = [@signalH, @signalL]
  @jarInfo    = [10, 3, 4]
  @payAmounts = [0.50, 0.10, 0.23, 0.43]
  @nPlayers   = 5
  @nRounds    = 6
  
  @playerNames  = []
  @results      = []
  @currName     = null
  @currSignal   = null
  @currReport   = null

  @chooseRandomly: (list) ->
    i = Math.floor(Math.random() * list.length)
    list[i]  
  
  @getGeneralInfo: -> 
    # Message received from server
    # format: --------------------
    #       status:     startRound
    #       numPlayers: 
    #       playerNames: 
    #       yourName: 
    #       numRounds: 
    #       payments:
    #       signalList: 
    # -------------------------
    for i in [0..(@nPlayers - 1)]
      @playerNames.push "Player #{i}"
    
    rndIndex = Math.floor(Math.random() * @playerNames.length)
    @currName = @playerNames[rndIndex]

    msg = 
      "status"      : "startRound"
      "numPlayers"  : @nPlayers
      "numRounds"   : @nRounds
      "playerNames" : @playerNames
      "yourName"    : @currName 
      "payments"    : @payAmounts
      "signalList"  : @signalList
    
  @getRoundSignal: ->
    @currSignal = null
    @currReport = null

    # Message received from server
    # format: -----------------
    #     status: signal
    #     signal: 
    # -------------------------
    @currSignal = @chooseRandomly(@signalList)
    
    # create result object
    game = 
      'signal': @currSignal
      'reportConfirmed': {}
      'result': {}
    for name in @playerNames
      game.reportConfirmed[name] = false
    @results.push game
    # console.log "results are #{JSON.stringify(@results)}}"
    
    
    msg = 
      "status:" : "signal"
      "signal"  : @currSignal
    
  @getResult: ->
    # Message received from server
    # format: --------------
    #     status: results
    #     result: 
    # ----------------------
    msg = 
      "status": "results"
      "result": {}
      
    # We should have the reports already
    for name in @playerNames
      msg.result[name] = {}
      if name is @currName
        msg.result[@currName].report = @currReport
      else 
        msg.result[name].report = @chooseRandomly(@signalList)
      
    # this is getting the reference players
    for name, i in @playerNames
      refIndex = Math.floor(Math.random() * (@nPlayers - 1))
      if i <= refIndex
        refIndex = refIndex  + 1
      msg.result[name].refPlayer = @playerNames[refIndex]

    # determine the rewards
    for name in @playerNames
      theReport     = msg.result[name].report
      theRefPlayer  = msg.result[name].refPlayer
      theRefReport  = msg.result[theRefPlayer].report
      msg.result[name].reward = @getPayment(theReport, theRefReport)
      
    msg
  
  # send report by current player to server
  @sendReportToServer: (report) ->
    @currReport = report
    
    # update result object
    @results[@results.length - 1].result[@currName] = {}
    @results[@results.length - 1].result[@currName].report = report
    # console.log "results are #{JSON.stringify(@results)}}"
  
  @getConfirmReport: ->
    
    @game = Game.last()
    playerNotConfirmed = []
    for name in Object.keys(@game.reportConfirmed)
      if name is @currName and @currReport is null
      else 
        if @game.reportConfirmed[name] is false
          playerNotConfirmed.push name

    # just waiting for report from the current player
    if playerNotConfirmed.length is 0
      return null

    # Message received from the server
    # format: -------------------
    #    status: confirmReport
    #    playerName: 
    # ---------------------------
    rnd = Math.floor(Math.random() * playerNotConfirmed.length)
    reporter = playerNotConfirmed[rnd]

    # update result object
    @results[@results.length - 1].reportConfirmed[reporter] = true
    # console.log "results are #{JSON.stringify(@results)}}"

    msg = 
      "status"      : "confirmReport"
      "playerName"  : reporter 


  @getPayment: (report, refReport) ->
    left  = @signalList.indexOf(report)
    right = @signalList.indexOf(refReport)
    index = left * 2 + right
    return @payAmounts[index]    
  
module.exports = MockServer