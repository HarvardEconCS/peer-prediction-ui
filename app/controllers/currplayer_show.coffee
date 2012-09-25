Spine = require('spine')

class CurrplayerShow extends Spine.Controller
  constructor: ->
    super
    @active @render()

  render: ->
    @html require('views/currplayerinfo')({signal: @signal})
    console.log("curr player signal is #{@signal}")
                                    
module.exports = CurrplayerShow