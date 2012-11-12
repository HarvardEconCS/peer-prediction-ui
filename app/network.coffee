
Game    = require 'models/game'

class Network
  
  # static variables
  @signalH:     "MM"
  @signalL:     "GM"
  @signalList:  [@signalH, @signalL]
  @jarInfo:     [10, 3, 4]
  @defaultOption: "default"
  @confirmMsg:    "checkmarkgreen"
  @unconfirmMsg:  "questionmarkred"
  
  @fakeServer: true
  @task: null
  
  @intervalId: null
  @currPlayer: null
  
  @finished: false
  
  # Initialize fake server
  @initFake: ->	
    Network.currPlayer = 'turkId3'

  # Initialize real server
  @init: ->
    Network.fakeServer = false

  # Configure controllers for callback
  @setControllers: (taskController) ->
    Network.task = taskController

  @ready: ->
    if Network.fakeServer
      console.log "Network.ready:"
      Game.init()
      setTimeout Network.getGeneralInfo, 2000
    else

  # repeated called to get action updates from server
  @updateActions: ->
    console.log "updating actions is called"
    
    ################################################
    # get new status from server
    @game = Game.last()
    notActedArray = []
    for status, i in @game.otherStatus
      notActedArray.push i if status is false
    rnd = Math.floor(Math.random() * notActedArray.length)
    acted = notActedArray[rnd]
    ##############################################

    # update interface
    console.log "changing status for player #{acted} to be true"
    @game = Game.last()
    @game.otherStatus[acted] = true
    @game.otherActed += 1
    @game.save()
    Network.task.render()

    # check if other players have acted
    if @game.otherActed is (Network.numPlayers - 1)
      console.log "all other players have acted, stop getting action updates."
      clearInterval(Network.intervalId)
      
      if @game.result?   # if the result array exists, then the player must have confirmed report already
        console.log "load the next game."
        Network.getGameResult()
    
    
  # start the first game    
  @getGeneralInfo: ->

    ####################################################
    # Message received from server
    receivedMsg = 
      numPlayers: 4
      numTotal: 10
      payAmounts: [0.58, 0.36, 0.43, 0.54]
    ####################################################
    console.log "received msg: #{JSON.stringify(receivedMsg)}"
      
    # save metadata
    Network.payAmounts  = receivedMsg.payAmounts
    Network.numPlayers  = receivedMsg.numPlayers
    Network.numTotal    = receivedMsg.numTotal 
    
    # if there are only 2 players, no point to aggregate the information
    if Network.numPlayers is 2
      Network.task.agg = false
    Network.numPlayed   = 0

    # get information for the next game
    Network.getNextGameInfo()

    
  @getNextGameInfo: ->
    
    ####################################################
    # Message received from server
    nextSignal = Network.chooseRandomly(Network.signalList)
    ####################################################
    
    # we know this because this is the first game
    otherStatusList = []
    for i in [1..(Network.numPlayers - 1)]
      otherStatusList.push false
    
    gameState =
      numPlayed:      Network.numPlayed
      signal:         nextSignal 
      otherActed:     0
      otherStatus:    otherStatusList
    
    # update interface
    Network.task.gotGameState(gameState)
    Network.task.render()
    
    # get updates from the server
    Network.intervalId = setInterval Network.updateActions, 5000
    
    
    
  # get next game
  @getGameResult: ->    
    
    ##########################################
    # Message received from server
    receivedActionList = []
    for i in [1..(Network.numPlayers - 1)]
      receivedActionList.push Network.chooseRandomly(Network.signalList)
      
    refPlayerList = []
    for i in [0..(Network.numPlayers - 1)]
      random = Math.floor(Math.random() * (Network.numPlayers - 1))
      if i <= random
        random = random + 1
      refPlayerList.push random
    ##########################################

    @game = Game.last()
    actionList = [@game.result[0].action].concat receivedActionList

    for i in [0..(Network.numPlayers - 1)]
      if i > 0
        @game.result.push {}
        @game.result[i].action = receivedActionList[i-1]
                
      @game.result[i].refPlayer = refPlayerList[i]
      @game.result[i].refReport = actionList[refPlayerList[i]]
      @game.result[i].reward = Network.getPayment(actionList[i], actionList[refPlayerList[i]])
    @game.save()
    
    count = 0
    if @game.result?
      for playerResult, i in @game.result
        if i > 0
          if playerResult.action is Network.signalList[0]
            count = count + 1
    @game.numSignal0 = count
    @game.save()
    
    Network.task.render()

    # Check if we are finished with all games
    Network.numPlayed += 1
    if Network.numPlayed is Network.numTotal
      Network.task.finish()
      return
    
    # get information for the next game
    Network.getNextGameInfo()
    


  @chooseRandomly: (list) ->
    i = Math.floor(Math.random() * list.length)
    list[i]

  @getPayment: (report, refReport) ->
    left = Network.signalList.indexOf(report)
    right = Network.signalList.indexOf(refReport)
    index = left * 2 + right
    return Network.payAmounts[index]

module.exports = Network