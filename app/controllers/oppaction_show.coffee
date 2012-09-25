Spine = require('spine')

class OppactionShow extends Spine.Controller
  constructor: ->
    super
    @render(@numOpps, @numOpps)

  render: (numNotActed, numOpps)->
    @html require('views/oppinfo')({numNotActed: numNotActed, numOpps: numOpps})
            
module.exports = OppactionShow