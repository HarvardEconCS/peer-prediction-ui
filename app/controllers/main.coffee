Spine = require('spine')

# models
Player    = require('models/player')
GameGroup = require('models/gamegroup')
Game      = require('models/game')
Action    = require('models/action')

#controllers
GameInfoShow   = require('controllers/gameinfo_show')
GameResultShow = require('controllers/gameresult_show')
CurrPlayerShow = require('controllers/currplayer_show')
OppActionShow  = require('controllers/oppaction_show')
ChooseAction   = require('controllers/chooseaction')

class Main extends Spine.Controller
  constructor: ->
    super
    
    # get data from server
    @loadData()
    
    # set up experiment
    @setupExp()

      
  loadData: ->

    @deleteAllData()
    
    @createData()

    @displayData()
    
    Player.fetch()
    GameGroup.fetch()
    Game.fetch()
    Action.fetch()

  deleteAllData: ->
    Player.destroyAll()
    GameGroup.destroyAll()
    Game.destroyAll()
    Action.destroyAll()

  createData: ->
    Player.create({turkId: 'turkId1', qualStatus: true}).save()
    Player.create({turkId: 'turkId2', qualStatus: true}).save()
    Player.create({turkId: 'turkId3', qualStatus: true}).save()
    playerIds = []
    Player.each (player) -> playerIds.push(player.id)
    GameGroup.create({numGames: 10, numPlayed: 0, playerIds: playerIds}).save() # init game group

    currPlayerIndex = Math.floor(Math.random() * 3)
    currPlayer = Player.all()[currPlayerIndex]
    @currPlayerId = currPlayer.id

    @currGroupId = GameGroup.first().id
    
  
  displayData: ->
    console.log("players: #{JSON.stringify(Player.all())}")
    console.log("gamegroups: #{JSON.stringify(GameGroup.all())}")
    console.log("games: #{JSON.stringify(Game.all())}")
    console.log("actions: #{JSON.stringify(Action.all())}")

  
  setupExp: ->

    @gameinfoshow = new GameInfoShow # show general information of the game
    @gameresultshow = new GameResultShow # show existing results of games
    @append @gameinfoshow, @gameresultshow

    currGroup = GameGroup.find(@currGroupId)
    if currGroup.numPlayed < currGroup.numGames
      
      console.log("there is more games to be played")

      # create and save game object
      @currGame = Game.create({groupId: @currGroupId, chosenJar: "A", done: false})
      @currGame.save()
      @currGameId = @currGame.id
      console.log("current game #{JSON.stringify(@currGame)}")

      # create and save action object
      action = Action.create({gameId: @currGameId, playerId: @currPlayerId})
      action.save()

      # show private information for current player
      # this controller will take care of choosing a signal and creating the action object
      @currPlayerAction = Action.select (a) => a.gameId is @currGameId and a.playerId is @currPlayerId
      @currplayershow = new CurrPlayerShow
        currPlayerAction: @currPlayerAction[0] # we should only find 1 record for a given gameId and playerId

      # show action menu choice for current player
      @chooseaction = new ChooseAction
      
      # show whether the opponents have chosen their actions
      @oppactionshow = new OppActionShow
        numOpps: currGroup.playerIds.length - 1

      @append @currplayershow, @chooseaction, @oppactionshow

module.exports = Main