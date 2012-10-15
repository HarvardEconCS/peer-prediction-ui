
Game    = require 'models/game'
Result  = require 'models/result'

class Network
  
  # static variables
  @fakeServer: true
  @currPlayerTurkId: null
  @gameinfo: null
  @gameresult: null
  @signalList: ['Red', 'Green']
  @intervalId: null
  @action: null

  # Initialize fake server
  @initFake: ->	
    Network.currPlayerTurkId = 'turkId3'

  # Initialize real server
  @init: ->
    Network.fakeServer = false

  # Configure controllers for callback
  @setControllers: (info, result) ->
    Network.gameinfo = info
    Network.gameresult = result

  @ready: ->
    if Network.fakeServer
      console.log "Network.ready:"
      setTimeout Network.startGame, 2000
      
    else

  @updateActions: ->
    console.log "updating actions"
    
    return unless Game.count() > 0    
    @game = Game.first()
    
    if @game.otherStatus[0] is true and @game.otherStatus[1] is true and Network.action isnt null
      console.log "we are ready for the next game."
      clearInterval(Network.intervalId)
      Network.nextGame()
      return
    else if @game.otherStatus[0] is true and @game.otherStatus[1] is true
      console.log "all other players have acted."
      return
    
    # get new status from server
    newStatus = []
    changed = false
    for status in @game.otherStatus
      if status is false
        random = Math.floor(Math.random() * 2)
        changed = true if random is 0
        newStatus.push if random is 0 then true else false
      else
        newStatus.push true
    console.log "new status received from server is: #{newStatus}"
    
    # update local status if necessary
    Network.gameinfo.gotStatus(newStatus) if changed is true
        
    
  # start the first game    
  @startGame: ->
    # Pretend to have received message
    # {numPlayers, numTotal, numPlayed, payAmounts}        
    ReceivedMsg = 
      numPlayers: 3
      numTotal: 3
      numPlayed: 0
      payAmounts: [0.58, 0.36, 0.43, 0.54]
    
    Network.numPlayers  = ReceivedMsg.numPlayers
    Network.numTotal    = ReceivedMsg.numTotal 
    Network.numPlayed   = ReceivedMsg.numPlayed
    Network.payAmounts  = ReceivedMsg.payAmounts
              
    # Pretend to have received message
    # {numPlayers, numTotal, numPlayed, signal, otherPlayerIds, otherActed}
    gameState =
      numPlayers: Network.numPlayers
      numTotal:   Network.numTotal
      numPlayed:  Network.numPlayed
      signal:     Network.chooseRandomly(Network.signalList)
      otherPlayerIds: ['turkId1', 'turkId2']
      otherActed: 0
      otherStatus: [false, false]
              
    gameState.otherActed += 1 for status in gameState.otherStatus when status is true
              
    finished = if Network.numPlayed is Network.numTotal then true else false    
    Network.gameinfo.gotGameState 'gameState': gameState, 'finished': finished

    # Initialize results
    Result.init()
    Network.gameresult.gotResult(null)
    
    # get updates from the server
    Network.intervalId = setInterval Network.updateActions, 5000
    
    
  # get next game
  @nextGame: ->
    
    return unless Game.count() > 0 # impossible 
    @game = Game.first()
        
    # send action to server
    # server ends the game
    Network.numPlayed += 1
    
    # Pretend to have received message
    game = Game.first()
    resultInfo = [
      {turkId: 'turkId3', signal: game.signal, action: Network.action, refPlayer: 'turkId1', reward: Network.chooseRandomly(Network.payAmounts)}
      {turkId: 'turkId1', action: Network.chooseRandomly(Network.signalList), refPlayer: 'turkId2', reward: Network.chooseRandomly(Network.payAmounts)}
      {turkId: 'turkId2', action: Network.chooseRandomly(Network.signalList), refPlayer: 'turkId1', reward: Network.chooseRandomly(Network.payAmounts)}
    ]
    Network.gameresult.gotResult(resultInfo)

    # Pretend to have received message
    # {numPlayers, numTotal, numPlayed, signal, otherPlayerIds, otherActed}
    Network.action = null
    gameState =
      numPlayers: Network.numPlayers
      numTotal:   Network.numTotal
      numPlayed:  Network.numPlayed
      signal:     Network.chooseRandomly(Network.signalList)
      otherPlayerIds: ['turkId1', 'turkId2']
      otherActed: 0
      otherStatus: [false, false]      
 
    gameState.otherActed += 1 for status in gameState.otherStatus when status is true
    
    # get info of next game
    finished = if Network.numPlayed is Network.numTotal then true else false    
    Network.gameinfo.gotGameState 'gameState': gameState, 'finished': finished
    
    # get updates from the server
    Network.intervalId = setInterval Network.updateActions, 5000 unless finished

  @chooseRandomly: (list) ->
    i = Math.floor(Math.random() * list.length)
    list[i]

module.exports = Network