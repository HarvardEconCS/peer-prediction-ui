Spine = require('spine')

class Dropdown extends Spine.Controller
  className: 'help-wrap'
  
  elements:
    "#help-content": "helpContent"
    
  events:
    "click #help-tab a"                     : "helpClicked"
  
  constructor: ->
    super
    
  active: ->
    @render()
    
  render: ->
    @html require 'views/dropdown'
    

  helpClicked: (ev) ->
    ev.preventDefault()
    @helpContent.slideToggle()
    
module.exports = Dropdown