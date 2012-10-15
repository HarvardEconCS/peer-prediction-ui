Spine = require('spine')

class Intro extends Spine.Controller
  className: 'intro'
  
  events:
    'click button': 'goToTask'
  
  constructor: ->
    super
    
  active: ->
    super
    @render()
        
  render: ->
    @html require('views/intro')(@)
    
  goToTask: (e) ->
    e.preventDefault()
    @navigate '/task'
    
module.exports = Intro