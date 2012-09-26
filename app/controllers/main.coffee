Spine = require('spine')

# models
Player    = require('models/player')
Game      = require('models/game')
Result   = require('models/result')

#controllers
GameResultShow = require('controllers/gameresult_show')
GameInfoShow   = require('controllers/gameinfo_show')

class Main extends Spine.Controller
  
  constructor: ->
    super
    @setupExp()
    
  setupExp: ->

    # Get this from url parameters?
    @currPlayerTurkId = 'turkId3'

    # Get info of current game from server
    Game.getGameState()
    Result.getResults()

    @gameinfoshow = new GameInfoShow
      turkId: @currPlayerTurkId
  
    # TODO: should try to save results when there are games left
    @gameresultshow = new GameResultShow
      turkId: @currPlayerTurkId

    divide = Spine.$('<div />').addClass('vdivide')
    
    @append @gameinfoshow, divide, @gameresultshow



module.exports = Main