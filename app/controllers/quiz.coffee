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
    
  submitClicked: (ev) -> 
    ev.preventDefault()
    
    # validate answers and send them to server
    ans = 
      stepOneAns: []
      stepTwoAns: []
      stepThreeAns: []
      interfaceAns: []
    $('input:checkbox[name=step1]:checked').each ->
      ans.stepOneAns.push $(this).val()
    $('input:checkbox[name=step2]:checked').each ->
      ans.stepTwoAns.push $(this).val()
    $('input:checkbox[name=step3]:checked').each ->
      ans.stepThreeAns.push $(this).val()
    $('input:checkbox[name=interface1]:checked').each ->
      ans.interfaceAns.push $(this).val()
    ans.stepOneAns.sort()
    ans.stepTwoAns.sort()
    ans.stepThreeAns.sort()
    ans.interfaceAns.sort()
    
    # send answers to the server
    Network.sendQuizAns(ans)
    
    # @navigate "/task"
    
module.exports = Quiz