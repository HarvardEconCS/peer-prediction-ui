Spine = require('spine')

Game = require 'models/game'
Network = require 'network'

class Result extends Spine.Model
  @configure 'Result', 'data'

  @extend @Local

  @init: ->
    Result.destroyAll()
    
  # save the result retrieved from server
  @saveResult: (resultInfo) ->
    r = Result.create 'data': resultInfo
    r.save()
    Result.fetch()
    
    
module.exports = Result