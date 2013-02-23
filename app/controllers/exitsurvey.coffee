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
  
  submitClicked: (ev) ->
    ev.preventDefault()
    
    # retrieve comments
    bugComments = $('textarea#bugs').val()
    uiComments = $('textarea#uiComments').val()
    strategyComments = $('textarea#strategy').val()
    exitComments = {}
    if bugComments.length > 0
      exitComments.bugs = bugComments
    else 
      exitComments = exitComments + "no bugs; "
      
    if uiComments.length > 0
      exitComments = exitComments + "ui: #{uiComments}; "
    else 
      exitComments = exitComments + "no ui comments; "
    
    if strategyComments.length > 0
      exitComments = exitComments + "strategy: #{strategyComments}"
    else
      exitComments = exitComments + "no strategy comments; "
    
    Network.finalSubmit(exitComments)
  
  
module.exports = Exitsurvey