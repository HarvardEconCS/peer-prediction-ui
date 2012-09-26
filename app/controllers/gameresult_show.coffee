Spine = require('spine')

Result = require('models/result')

class GameresultShow extends Spine.Controller
  constructor: ->
    super

    @results = Result.all()
    @render()

  render: ->
    @html require('views/results')(@)

module.exports = GameresultShow