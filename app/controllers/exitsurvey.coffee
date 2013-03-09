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
    
    # TODO: check if all required questions are answers.
        
    # construct exit comments object
    exitComments = {}
    
    $('input:radio').each ->
      n = $(this).attr('name')
      exitComments[n] = {}
    for name in Object.keys(exitComments)
      exitComments[name]['value'] = $('input:radio[name='+name+']:checked').val()
      exitComments[name]['comments'] = $('textarea#'+name+'Comments').val()

    exitComments['strategy'] = {}
    $('input:checkbox[name=strategy]').each -> 
      i = $(this).attr('id')
      exitComments['strategy'][i] = {}
    for id in Object.keys(exitComments['strategy'])
      exitComments['strategy'][id]["value"] = $('input:checkbox#'+id).val()
      exitComments['strategy'][id]['checked'] = $('input:checkbox#'+id).is(':checked')     
    
    exitComments['strategy']['comments'] = $('textarea#strategyComments').val()
 
    # console.log "exitComments is #{JSON.stringify(exitComments)}"
 
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
      return
    else 
      Network.sendHITSubmitInfo(exitComments)
  
  
module.exports = Exitsurvey