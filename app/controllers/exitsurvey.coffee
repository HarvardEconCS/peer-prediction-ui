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

    # construct exit comments object
    exitComments = {}
    $('textarea').each ->
      i = $(this).attr('id')
      if not exitComments[i]?
        exitComments[i] = {}
    for id in Object.keys(exitComments)
      exitComments[id] = $('textarea#' + id).val()
      
    # send exit comments to server
    Network.sendHITSubmitInfo(exitComments)
  
  
module.exports = Exitsurvey