Spine = require('spine')

Result = require('models/result')

class GameresultShow extends Spine.Controller
  className: "result"
  
  constructor: ->
    super

  render: ->
    return unless @results
    @html require('views/results')(@)

  gotResult: ->
    @results = Result.all()
    @render()
    
module.exports = GameresultShow