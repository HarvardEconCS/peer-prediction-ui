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
    
    # retrieve comments
    bugComments       = $('textarea#bugComments').val()
    uiComments        = $('textarea#uiComments').val()
    strategyComments  = $('textarea#strategyComments').val()
    exitComments = {}
    exitComments.bug      = bugComments
    exitComments.ui       = uiComments
    exitComments.strategy = strategyComments
    
    Network.sendFinalInfo(exitComments)
  
  
module.exports = Exitsurvey