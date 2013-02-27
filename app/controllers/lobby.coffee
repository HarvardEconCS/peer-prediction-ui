Spine = require('spine')

class Lobby extends Spine.Controller
  className: 'lobby'
  
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/lobby')(@)  
    
module.exports = Lobby