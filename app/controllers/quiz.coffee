Spine = require('spine')
 
Network = require 'network'
 
class Quiz extends Spine.Controller
  className: 'quiz'

  events:
    "click a#quizSubmit": "submitClicked"

  constructor: ->
    super
    
  active: ->
    super
    @render()
    
  render: ->
    @signalList = ["MM", "GM"]
    @html require('views/quiz')(@)

    for i in [1..4]
      @randomizeChoices(i)
  
  submitClicked: (ev) -> 
    ev.preventDefault()
    
    # validate answers and send them to server
    ans = []
    $('input:checkbox[name=step1]:checked').each ->
      ans.push $(this).val()
    $('input:checkbox[name=step2]:checked').each ->
      ans.push $(this).val()
    $('input:checkbox[name=step3]:checked').each ->
      ans.push $(this).val()
    $('input:checkbox[name=interface1]:checked').each ->
      ans.push $(this).val()
    ans.sort()
      
    key = ['v14', 'v23', 'v34']
    key.sort()
    
    num = 0
    for ch in ans
      if key.indexOf(ch) is -1
        num++
    for ch in key
      if ans.indexOf(ch) is -1
        num++
        
    console.log "score is #{num}/15"

    # send answers to the server
    Network.sendQuizInfo(num)
    
    # @navigate "/task"
    
  randomizeChoices: (qNum)->
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