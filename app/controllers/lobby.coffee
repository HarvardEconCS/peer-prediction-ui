Spine = require('spine')

Network = require 'network'

class Lobby extends Spine.Controller
  className: 'lobby'
  
  events:
    "click a#readyButton" : "readyButtonClicked"
  
  constructor: ->
    super
    @data = null
    
    @enableButton = false
    
  active: ->
    super
    Network.updateLobbyStatus(false)
    @render()
    
  render: ->
    @html require('views/lobby')(@)  
    
  readyButtonClicked: (ev) =>
    ev.preventDefault()
    Network.updateLobbyStatus(true)
    @render()
    
  updateInfo: (data) ->
    # console.log JSON.stringify(data)
    
    @data = data
    @render()
    
#    if @data.joinenabled
#      audio = new Audio("sounds/44704__sandyrb__you-ready-here-we-go-01.wav")
#      audio.load()
#      audio.play()
    
module.exports = Lobby
