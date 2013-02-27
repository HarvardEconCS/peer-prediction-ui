Spine = require('spine')

class Errormessage extends Spine.Controller
  className: 'errorMessage'
      
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/errormessage')(@)  
    $('p#messagecontainer').html(@msg)    

  setMessage: (message) =>
    @msg = message
    
module.exports = Errormessage