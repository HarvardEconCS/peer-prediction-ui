Spine = require('spine')
$ = Spine.$

class Chooseaction extends Spine.Controller

  events:
    'submit form': 'chooseAction'

  #elements:
    #'select' : 'select'
    #'button' : 'button'
    #'form'   : 'form'
  
  constructor: ->
    super
    @render({})
      
  render: (input) ->
    @html require('views/chooseaction')(input)

  chooseAction: (e) ->
    e.preventDefault()
    action = @select.val()
    console.log("Chosen action is", action)
    @render({action: action})

    # changed template such that these are not displayed
    # if player has chosen an action
    #@button.attr("disabled", "disabled")
    #@select.attr("disabled", "disabled")
    
    # TODO: send action to the server
    ###
      $.post
        url: 'save_action.php'
        data: {turkId: @turkId, action: action}
        dataType: 'json'
        success: -> console.log("successfully sent action to server") 
    ###

            
module.exports = Chooseaction