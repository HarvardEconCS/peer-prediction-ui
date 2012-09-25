Spine = require('spine')

# models
Player    = require('models/player')
Game      = require('models/game')

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
    Game.newGame()
    @currGame = Game.first()

    # if there are games left to play
    if @currGame.numRemaining > 0

      @gameinfoshow = new GameInfoShow
        game: @currGame
        turkId: @currPlayerTurkId

      @append @gameinfoshow

    # TODO: should try to save results when there are games left
    @gameresultshow = new GameResultShow
      results: @currGame.results

    divide = Spine.$('<div />').addClass('vdivide')
    
    @append divide, @gameresultshow



module.exports = Main