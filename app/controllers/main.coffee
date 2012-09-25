Spine = require('spine')

# models
Player    = require('models/player')
Game      = require('models/game')

#controllers
GameInfoShow   = require('controllers/gameinfo_show')
GameResultShow = require('controllers/gameresult_show')
OppActionShow  = require('controllers/oppaction_show')
ChooseAction   = require('controllers/chooseaction')

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

    if @currGame.numRemaining > 0

      @gameinfoshow = new GameInfoShow
        game: @currGame
        turkId: @currPlayerTurkId

      @chooseaction = new ChooseAction
        turkId: @currPayerTurkId
      
      @oppactionshow = new OppActionShow
        numOpps: @currGame.numPlayers - 1

      @append @gameinfoshow, @chooseaction, @oppactionshow


    # TODO: should try to save results when there are games left
    @gameresultshow = new GameResultShow(results: @currGame.results)

    divide = Spine.$('<div />').addClass('vdivide')
    
    @append divide, @gameresultshow



module.exports = Main