Spine = require('spine')

Network = require 'network'

class Exitsurvey extends Spine.Controller
  className: 'exitsurvey'
    
  events:
    "click a#submitTask" : "submitClicked"
    
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/exitsurvey')(@)
  
  submitClicked: (ev) =>
    ev.preventDefault()
    
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
      return
    
    # retrieve comments
    bugComments       = $('textarea#bugComments').val()
    uiComments        = $('textarea#uiComments').val()
    strategyComments  = $('textarea#strategyComments').val()
    
    exitComments = {}
    exitComments.bug      = bugComments
    exitComments.ui       = uiComments
    exitComments.strategy = strategyComments
    
    Network.sendHITSubmitInfo(exitComments)
  
  
module.exports = Exitsurvey