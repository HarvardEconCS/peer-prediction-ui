Spine = require('spine')

Network = require 'network'

class Exitsurvey extends Spine.Controller
  className: 'exitsurvey'
  
  elements:
    "input:radio"     : "radiobuttons"
    "input:checkbox"  : "checkboxes"
    "textarea"        : "textareas"
    "input:checkbox#shouldContact" : "contactCheckbox"
    
  events:
    "click a#submitTask" : "submitClicked"
    
  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/exitsurvey')(@)
    
    @randomizeStrategyChoices()
  
  randomizeStrategyChoices: ->
    inputList = []
    labelList = []
    @checkboxes.filter('[name=strategy]').each ->
      inputList.push $(this)
      id = $(this).attr('id')
      labelList.push $('label[for='+id+']')
    
    newInputList = []
    newLabelList = []
    len = inputList.length
    randList = @randomizeList(len - 1)
    for index in randList
      newInputList.push(inputList[index])
      newLabelList.push(labelList[index])  
      
    # leave the last choice be, do not randomize
    newInputList.push(inputList[4])
    newLabelList.push(labelList[4])  
      
    $('td#strategyChoices').contents().remove()
    for input, i in newInputList
      $('td#strategyChoices').append(input)
      $('td#strategyChoices').append(newLabelList[i])
      $('td#strategyChoices').append("<br/>")
      
  randomizeList: (len) ->
    oldList = (num for num in [0..(len-1)])
    num = len
    newList = []
    
    while num > 0
      rand = Math.floor(Math.random() * num)
      newList.push(oldList[rand])
      oldList.splice(rand, 1)
      num = num - 1
    
    newList 
  
  submitClicked: (ev) =>
    ev.preventDefault()
    
    # check if all required questions are answered
    radioNames = []
    @radiobuttons.each ->
      n = $(this).attr('name')
      if radioNames.indexOf(n) < 0
        radioNames.push n
    notCheckedRadioNames = []
    for name in radioNames
      if not @radiobuttons.filter('[name='+name+']:checked').val()
        notCheckedRadioNames.push name
    # console.log "not answered check boxes #{JSON.stringify(notCheckedRadioNames)}"
        
    strategyChosen = false
    @checkboxes.filter('[name=strategy]').each ->
      if $(this).is(":checked")
        strategyChosen = true
    # console.log "strategy chosen #{strategyChosen}"
      
    strategyCommentFilled = $.trim(@textareas.filter('#strategyComments').val()).length > 0
    # console.log "strategy comments #{strategyCommentFilled}"
    
    learnCommentFilled = $.trim(@textareas.filter('textarea#learnComments').val()).length > 0
    # console.log "learn comments #{learnCommentFilled}"
    
    if notCheckedRadioNames.length > 0 or strategyChosen is false or strategyCommentFilled is false or learnCommentFilled is false
      alert "You haven't answered all the required questions.  Please check your answers and try again."
      return
        
    # construct exit comments object
    exitComments = {}
    
    @radiobuttons.each ->
      n = $(this).attr('name')
      exitComments[n] = {}
    for name in Object.keys(exitComments)
      exitComments[name]['value'] = @radiobuttons.filter('[name='+name+']:checked').val()
      exitComments[name]['comments'] = @textareas.filter('#'+name+'Comments').val()

    exitComments['strategy'] = {}
    @checkboxes.filter('[name=strategy]').each -> 
      i = $(this).attr('id')
      exitComments['strategy'][i] = {}
    for id in Object.keys(exitComments['strategy'])
      exitComments['strategy'][id]["value"] = @checkboxes.filter('#'+id).val()
      exitComments['strategy'][id]['checked'] = @checkboxes.filter('#'+id).is(':checked')     
    
    exitComments['strategy']['comments'] = @textareas.filter('#strategyComments').val()
    # console.log "comments: #{JSON.stringify(exitComments)}"
 
    # record if a worker wants to be contacted or not
    exitComments['shouldContact'] = not @contactCheckbox.is(":checked")
 
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
      return
    else 
      Network.sendHITSubmitInfo(exitComments)
  
  
module.exports = Exitsurvey