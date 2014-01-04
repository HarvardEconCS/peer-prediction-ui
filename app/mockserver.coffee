Game    = require 'models/game'

class MockServer
  
  # @signalH    = "MM"
  # @signalL    = "GB"
  @signalList = ["MM", "GB"]
  @payAmounts = [[0.10, 0.10, 1.50, 0.15],[0.15, 0.90, 0.15, 0.10]]
  @nPlayers   = 4
  @nRounds    = 30
  @houses     = [0.2, 0.7]

  @playerNames  = []
  @results      = []
  @currName     = null
  @currSignal   = null
  @currReport   = null

  @chooseRandomly: (list) ->
    i = Math.floor(Math.random() * list.length)
    list[i]  
  
  @getGeneralInfo: -> 

    # choose house
    @chosenHouse = 0
    numHouse = Math.random()
    if numHouse > 0.49
      @chosenHouse = 1

    for i in [0..(@nPlayers - 1)]
      @playerNames.push "Player #{i}"
    
    rndIndex = Math.floor(Math.random() * @playerNames.length)
    @currName = @playerNames[rndIndex]

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

    # choose signal
    @currSignal= "MM"
    numCandy = Math.random()
    if numCandy > @houses[@chosenHouse]
      @currSignal= "GB"

    # create result object
    game = 
      'signal': @currSignal
      'reportConfirmed': {}
      'result': {}
    for name in @playerNames
      game.reportConfirmed[name] = false
    @results.push game
    # console.log "results are #{JSON.stringify(@results)}}"
    
    # Message received from server
    # format: -----------------
    #     status: signal
    #     signal: 
    # -------------------------    
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
        @otherReport= "MM"
        numCandy = Math.random()
        if numCandy > @houses[@chosenHouse]
          @otherReport= "GB"
        msg.result[name].report = @otherReport

    # determine the rewards
    for name in @playerNames
      msg.result[name].reward = 0.90

#      theReport     = msg.result[name].report

#      numOtherMMReports = 0
#      for playerName in @playerNames
#        if playerName isnt name and msg.result[playerName].report is "MM"
#          numOtherMMReports++
      
#      msg.result[name].reward = @getPayment(theReport, numOtherMMReports)

    # console.log msg
    msg
  
  # send report by current player to server
  @sendReportToServer: (report, randomRadio) ->
    @currReport = report
#    console.log "server: random radio is #{randomRadio}"
    
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


  @getPayment: (report, numOtherMMReports) ->
    reportIndex  = @signalList.indexOf(report)
    return @payAmounts[reportIndex][numOtherMMReports]    
  
module.exports = MockServer