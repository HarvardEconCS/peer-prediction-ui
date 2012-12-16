Spine = require('spine')

class Exitsurvey extends Spine.Controller
  className: 'exitsurvey'
    
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/exitsurvey')(@)
  
module.exports = Exitsurvey