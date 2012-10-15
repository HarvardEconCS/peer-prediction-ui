Spine = require('spine')
Game = require 'models/game'
Result = require 'models/result'
Network = require 'network'

class GameresultShow extends Spine.Controller
  className: "result"
  
  constructor: ->
    super
    @turkId = null
    @results = null
    @numPlayers = 0

  render: ->
    @turkId = Network.currPlayerTurkId
    @html require('views/results')(@)

  gotResult: (resultInfo) ->
    @numPlayers = Network.numPlayers    
    Result.saveResult(resultInfo) if resultInfo
    @results = if Result.count() > 0 then Result.all() else null
    
    @render()
    
module.exports = GameresultShow