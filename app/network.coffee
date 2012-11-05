
Game    = require 'models/game'

class Network
  
  # static variables
  @signalH: "MM"
  @signalL: "CH"
  @signalList: [@signalH, @signalL]
  @jarInfo: [10, 3, 4]
  @defaultOption: "default"
  
  @fakeServer: true
  @gameinfo: null
  
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
  @setControllers: (info) ->
    Network.gameinfo = info

  @ready: ->
    if Network.fakeServer
      console.log "Network.ready:"
      Game.init()
      setTimeout Network.startGame, 2000
    else


  @updateActions: ->
    console.log "updating actions is called"

    # get the current game
    @game = Game.last()
    
    ################################################
    # get new status from server   TODO: separate detecting change from server message
    newStatus = []
    changed = false
    for status in @game.otherStatus
      if status is false
        random = Math.floor(Math.random() * 2)
        if random is 0
          changed = true
          newStatus.push true
        else 
          newStatus.push false
      else
        newStatus.push true
    ##############################################

    
    # update interface
    if changed is true
      console.log "changing status to: #{newStatus}"
      @game.otherStatus = newStatus
      @game.otherActed = 0
      @game.otherActed += 1 for status in @game.otherStatus when status is true
      @game.save()
      Network.gameinfo.render()

    # check if other players have acted
    allOtherActed = true
    for i in [0..(Network.numPlayers - 2)]
      if newStatus[i] is false
        allOtherActed = false
        
    if allOtherActed is true
      console.log "all other players have acted, stop getting action updates."
      console.log "clearing interval #{Network.intervalId}"
      clearInterval(Network.intervalId)
      
      if @game.result?   # if the result array exists, then the player must have confirmed report already
        console.log "load the next game."
        Network.nextGame()
    
    
  # start the first game    
  @startGame: ->

    ####################################################
    # Message received from server
    receivedMsg = 
      numPlayers: 3
      numTotal: 3
      payAmounts: [0.58, 0.36, 0.43, 0.54]
      signal: Network.chooseRandomly(Network.signalList)
    ####################################################
    console.log "received msg: #{JSON.stringify(receivedMsg)}"
      
    # save metadata
    Network.payAmounts  = receivedMsg.payAmounts
    Network.numPlayers  = receivedMsg.numPlayers
    Network.numTotal    = receivedMsg.numTotal 
    
    # we know this because this is the first game
    Network.numPlayed   = 0
     
    otherStatusList = []
    for i in [1..(Network.numPlayers - 1)]
      otherStatusList.push false
     
    gameState =
      numPlayed:      Network.numPlayed
      signal:         receivedMsg.signal
      otherActed:     0
      otherStatus:    otherStatusList
    
    # update interface
    Network.gameinfo.gotGameState(gameState)
    Network.gameinfo.render()
    
    # get updates from the server
    Network.intervalId = setInterval Network.updateActions, 5000
    console.log "interval id is #{Network.intervalId}"
    
  # get next game
  @nextGame: ->    
    
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
      
    nextSignal = Network.chooseRandomly(Network.signalList)
    ##########################################
    console.log "msg from server:  receivedActionList = #{receivedActionList}, refPlayerList = #{refPlayerList}, nextSignal = #{nextSignal}"


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
    Network.gameinfo.render()

    Network.numPlayed += 1
    if Network.numPlayed is Network.numTotal
      Network.gameinfo.finish()
      return
    
    
    otherStatusList = []
    for i in [1..(Network.numPlayers - 1)]
      otherStatusList.push false
      
    gameState =
      numPlayed:  Network.numPlayed
      signal:     nextSignal
      otherActed: 0
      otherStatus: otherStatusList      
    
    # update interface
    Network.gameinfo.gotGameState(gameState)
        
    # get updates from the server
    Network.intervalId = setInterval Network.updateActions, 5000
    console.log "interval id is #{Network.intervalId}"


  @chooseRandomly: (list) ->
    i = Math.floor(Math.random() * list.length)
    list[i]

  @getPayment: (report, refReport) ->
    left = Network.signalList.indexOf(report)
    right = Network.signalList.indexOf(refReport)
    index = left * 2 + right
    return Network.payAmounts[index]

module.exports = Network