Spine = require('spine')

class Lobby extends Spine.Controller
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/lobby')(@)  
    
module.exports = Lobby