Spine = require('spine')
 
Network = require 'network'
 
class Quiz extends Spine.Controller
  className: 'quiz'

  events:
    "click a#quizSubmit"        : "submitClicked"
    "click a#goBackToTutorial"  : "goBackToTutorialClicked" 

  constructor: ->
    super
    
    @signalList = ["MM", "GB"]
    @wrongAnswers   = undefined
    @checkedValues  = undefined
    
  active: ->
    super
    @render()
    
  render: ->
    @html require('views/quiz')(@)

    if not @checkedValues
      for i in [1..4]
        @randomizeChoices(i)
  
  goBackToTutorialClicked: (ev) =>
    ev.preventDefault()
    @navigate "/tutorial"
  
  submitClicked: (ev) => 
    ev.preventDefault()
    
    # for rendering after failing
    checkedValuesRaw = []
    $('input:checkbox:checked').each ->
      checkedValuesRaw.push $(this).val()
    @checkedValues = checkedValuesRaw
    
    # validate checkedIdswers and send them to server
    checkedIds = []
    $('input:checkbox:checked').each ->
      checkedIds.push $(this).attr('id')
    checkedIds.sort()
      
    key = ['q14', 'q23', 'q34']
    key.sort()
    
    correct = 0
    for checkedId in checkedIds
      if key.indexOf(checkedId) is -1
        # checked choice is correct
        correct++
        
    for eachKey in key
      if checkedIds.indexOf(eachKey) is -1
        # wrong choice is not checked
        correct++
        
    total= $('input:checkbox').length    

    checkedChoices = {}
    $('input:checkbox:checked').each ->
      n = $(this).attr('name')
      if not checkedChoices[n]?
        checkedChoices[n] = []
      checkedChoices[n].push $(this).val()
    console.log "checked choices are #{JSON.stringify(checkedChoices)}"

    @wrongAnswers = @listWrongQuestions()
    # console.log "wrong answers are #{JSON.stringify(@wrongAnswers)}"

    if Network.fakeServer
      @navigate '/task'
    else
      console.log "sending quiz results to server"
      
      # For testing convenience.  TAKE OUT
      correct = 14
      total = 14
      Network.sendQuizInfo(correct, total, checkedChoices)
    
  # for rendering quiz after fail
  # get list of questions answered incorrectly
  listWrongQuestions: ->
    list = []
    for i in [1..4]
      if @isQuestionWrong(i) is true
        list.push i
    return list

  # for rendering quiz after fail    
  # check if a question is answered incorrectly
  isQuestionWrong: (qNum) ->
    if qNum is 1
      qName = 'step1'
      key = ['q14']
    else if qNum is 2
      qName = 'step2'
      key = ['q23']
    else if qNum is 3
      qName = 'step3'
      key = ['q34']
    else if qNum is 4
      qName = 'interface1'
      key = []
      
    key.sort()      
    checkedIds = []
    $('input:checkbox[name=' + qName + ']:checked').each ->
      checkedIds.push $(this).attr('id')
    checkedIds.sort()
      
    correct = 0
    for checkedId in checkedIds
      if key.indexOf(checkedId) is -1
        # checked choice is correct
        correct++
        
    for eachKey in key
      if checkedIds.indexOf(eachKey) is -1
        # wrong choice is not checked
        correct++

    total = $('input:checkbox[name=' + qName + ']').length
    if (correct < total)      
      return true
    else
      return false

  randomizeChoices: (qNum) ->
    inputList = []
    labelList = []
    choices = $('span#q'+qNum+'choices')
    len = choices.contents().length / 2
    for num in [1..len]
      inputList.push($('input:checkbox#q'+qNum+num))
      labelList.push($('label#l'+qNum+num))
    
    newInputList = []
    newLabelList = []
    randList = @randomizeList(len)
    for index in randList
      newInputList.push(inputList[index])
      newLabelList.push(labelList[index])
    
    choices.contents().remove()
    for input, i in newInputList
      choices.append(input)
      choices.append(newLabelList[i])
    
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
      
    
module.exports = Quiz