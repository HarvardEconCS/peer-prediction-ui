Spine = require('spine')

class Homepage extends Spine.Controller
  
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
    @navigate '/tutorial'
  
module.exports = Homepage