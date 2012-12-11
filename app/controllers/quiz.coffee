Spine = require('spine')
 
Network = require 'network'
 
class Quiz extends Spine.Controller
  className: 'quiz'

  events:
    "click a#quizSubmit": "submitClicked"

  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @signalList = Network.signalList unless @signalList
    @html require('views/quiz')(@)
    
  submitClicked: (ev) -> 
    ev.preventDefault()
    @navigate "/task"
    
module.exports = Quiz