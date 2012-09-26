Spine = require('spine')

class Result extends Spine.Model
  @configure 'Result', 'data'

  @constructor: (receivedResult) ->
    @data = receivedResult

  @getResults: ->
    receivedResult = [
      [
        {turkId: 'turkId1', action: 'Green', refPlayer: 'turkId2', reward: '0.50'}
        {turkId: 'turkId2', action: 'Green', refPlayer: 'turkId1', reward: '0.30'}
        {turkId: 'turkId3', signal: 'Green', action: 'Red', refPlayer: 'turkId1', reward: '0.90'}
      ]
      [
        {turkId: 'turkId1', action: 'Green', refPlayer: 'turkId2', reward: '0.23'}
        {turkId: 'turkId2', action: 'Green', refPlayer: 'turkId1', reward: '0.64'}
        {turkId: 'turkId3', signal: 'Red', action: 'Red', refPlayer: 'turkId1', reward: '0.18'}
      ]
      ]
      
    @createResult(receivedResult)

  @createResult: (receivedResult) ->
    Result.destroyAll()
    for record in receivedResult
      r = Result.create
        data: record
      r.save()
      
    console.log("game results are #{JSON.stringify(Result.all())}")
    Result.fetch()

    
module.exports = Result