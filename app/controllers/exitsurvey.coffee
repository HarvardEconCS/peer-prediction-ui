Spine = require('spine')

Network = require 'network'

class Exitsurvey extends Spine.Controller
  className: 'exitsurvey'
  
  elements:
    "input:checkbox"  : "checkboxes"
    "textarea"        : "textareas"
    "div#exitErrorMsg" : "divErrorMsg"
    
  events:
    "click a#submitTask" : "submitClicked"
    "click a#returnToSurvey" : "returnToSurveyClicked"
    "click input:checkbox#strategy5" : "changedOtherStrategy"
    
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
      
    $('span#strategyChoices').contents().remove()
    for input, i in newInputList
      $('span#strategyChoices').append(input)
      $('span#strategyChoices').append(newLabelList[i])
      $('span#strategyChoices').append("<br/>")
      
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
  
  changedOtherStrategy: (ev) =>
    if @checkboxes.filter("#strategy5").is(":checked")
      @textareas.filter("#otherStrategy").removeAttr("disabled")
    else 
      @textareas.filter("#otherStrategy").attr("disabled", "disabled")
  
  returnToSurveyClicked: (ev) =>
    ev.preventDefault()
    @divErrorMsg.hide()
  
  submitClicked: (ev) =>
    ev.preventDefault()
    
    @divErrorMsg.contents().remove()
    @divErrorMsg.append "ERROR: You have not answered all required questions!"

    valid = true
        
    strategyChosen = false
    count = 0
    @checkboxes.filter('[name=strategy]').each ->
      if $(this).is(":checked")
        strategyChosen = true
        count++
        
    if strategyChosen is false
      valid = false
      @divErrorMsg.append "<p>Please choose at least 1 stategy for question 1.</p>"

    otherStrategyChecked = @checkboxes.filter('#strategy5').is(":checked")
    if otherStrategyChecked is true  and count > 1
      valid = false
      @divErrorMsg.append "<p>If you checked the last option for question 1, you should not check any other option in question 1.</p>"
    
    otherStrategyFilled = $.trim(@textareas.filter('#otherStrategy').val()).length > 0
    if otherStrategyChecked is true and otherStrategyFilled is false
      valid = false
      @divErrorMsg.append "<p>Please answer question 2 since you checked the last option for question 1.</p>"

    strategyReasonFilled = $.trim(@textareas.filter('#strategyReason').val()).length > 0
    if strategyReasonFilled is false
      valid = false
      @divErrorMsg.append "<p>Please answer question 3.</p>"

    strategyChangeFilled = $.trim(@textareas.filter('#strategyChange').val()).length > 0
    if strategyChangeFilled is false
      valid = false
      @divErrorMsg.append "<p>Please answer question 4.</p>"
    
    if valid is false
      @divErrorMsg.append "<a class=\"button\" id=\"returnToSurvey\" href=\"#\">Return to survey</a><br/><br/>"
      @divErrorMsg.show()
      return
        
    # construct exit comments object
    exitComments = {}
    
    exitComments['strategy'] = {}
    @checkboxes.filter('[name=strategy]').each -> 
      i = $(this).attr('id')
      exitComments['strategy'][i] = {}
    for id in Object.keys(exitComments['strategy'])
      exitComments['strategy'][id]["value"] = @checkboxes.filter('#'+id).val()
      exitComments['strategy'][id]['checked'] = @checkboxes.filter('#'+id).is(':checked')     
    
    exitComments['strategy']['otherStrategy'] = @textareas.filter('#otherStrategy').val()
    exitComments['strategy']['strategyReason'] = @textareas.filter('#strategyReason').val()
    exitComments['strategy']['strategyChange'] = @textareas.filter('#strategyChange').val()

    exitComments['comments'] = @textareas.filter('#comments').val()
 
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
      return
    else 
      Network.sendHITSubmitInfo(exitComments)
  
  
module.exports = Exitsurvey