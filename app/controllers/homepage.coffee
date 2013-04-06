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
  
  buttonClicked: (ev) =>
    ev.preventDefault()
    
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
      
      # Change this based on the type of quiz
      @navigate '/tutorial'
    else if Network.showTutorial
      @navigate '/tutorial'
    else if Network.showRecap
      @navigate '/notice'
    else if Network.showLobby
      @navigate '/lobby'


module.exports = Homepage