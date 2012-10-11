
Game = require 'models/game'
Result = require 'models/result'

class Network
  fakeServer = true
  gameinfo = null
  gameresult = null

  @initFake: ->	

  @init: ->
    fakeServer = false

  # Configure controllers for callback
  @setGameInfo: (info, result) ->
    gameinfo = info
    gameresult = result

  # we are ready to start the game
  @ready: ->
    if fakeServer
      console.log "get game state"
      
      loadfun = ->
        Game.getGameState()
        gameinfo.gotGameState()
        
      setTimeout loadfun, 1000
    else

  # send action to server
  @sendAction: (action) ->
    if fakeServer
      console.log "sending action: #{action}"
      
      loadfun = ->
        Result.getResults()
        gameresult.gotResult()
        
      setTimeout loadfun, 1000
      
    else
      $.post
        url:      'save_action.php'
        data:     {turkId: @turkId, action: action}
        dataType: 'json'
        success:  -> console.log("successfully sent action to server") 

module.exports = Network