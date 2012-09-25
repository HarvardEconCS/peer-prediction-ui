Spine = require('spine')

class GameresultShow extends Spine.Controller
  constructor: ->
    super
    @render()

  render: ->
    @html require('views/results')()

            
module.exports = GameresultShow