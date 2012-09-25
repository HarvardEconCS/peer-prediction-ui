Spine = require('spine')

class OppactionShow extends Spine.Controller
  constructor: ->
    super
    @render(@numOpps)

  render: (@numNotActed)->
    @html require('views/oppinfo')({numNotActed: @numNotActed, numOpps: @numOpps})

  # TODO: add method to listen for changes in opponent actions
                                    
module.exports = OppactionShow