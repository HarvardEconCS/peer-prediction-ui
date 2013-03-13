Spine = require('spine')

class Lobby extends Spine.Controller
  className: 'lobby'
  
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    # console.log "#{@totalRequired}"
    @html require('views/lobby')(@)  
    
  setNum: (totalRequired, numJoined) ->
    @totalRequired = totalRequired
    @numJoined = numJoined
    
module.exports = Lobby
