Spine = require('spine')

class Chooseaction extends Spine.Controller
  constructor: ->
    super
    @render()

  render: ->
    @html require('views/chooseaction')()

            
module.exports = Chooseaction