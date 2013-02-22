Spine = require('spine')

Network = require 'network'

class Homepage extends Spine.Controller
  className: 'homepage'
  
  events:
    "click a#startExperiment": "buttonClicked"
  
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/homepage')(@)
  
  buttonClicked: (ev) ->
    ev.preventDefault()
    if Network.fakeServer
      @navigate '/tutorial'
    else if Network.showQuiz
      @navigate '/tutorial'
    else if Network.showLobby
      @navigate '/lobby'
  
module.exports = Homepage