Spine = require('spine')

Network = require 'network'

class Quiz extends Spine.Controller
  className: 'quizCont'

  elements:
    "img#screenshot" : "imgScreenshot"
    "span#quiz-step1"       : "spanStep1"
    "span#quiz-step3"       : "spanStep3"
    "span#quiz-step4"       : "spanStep4"
    "img#quiz-step1-prior"  : "imgStep1"
    "img#quiz-step3-example"    : "imgStep3"
    "div#quiz-step3-ruleTable"  : "divStep3RuleTable"
    "img#quiz-int-prior"      : "imgIntPrior"
    "div#quiz-int-ruleTable"  : "divIntRuleTable"
    "div#quizErrorMsg" : "quizErrorMsg"
    "a#quizSubmit" : "buttonSubmit"

  events:
    "click a#quizSubmit"        : "submitClicked"
    "click a#goBackToTutorial"  : "goBackToTutorialClicked"
    "click a#toggleScreenshot"  : "toggleScreenshotClicked"
    "click a#returnToQuiz"      : "returnToQuizClicked"

  constructor: ->
    super

    @signals = ['MM', 'GB']
    # needs to be changed if actual payment rule changes.
    @payRule = [[0.10, 0.10, 1.50, 0.15],[0.15, 0.90, 0.15, 0.10]]

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

    # randomize order of rows in reward rule table
    @randomizeRuleTable('quiz-step3-ruleTable')
    @randomizeRuleTable('quiz-int-ruleTable')

    refTop = @spanStep1.position().top
    imgStep1Top = refTop + 29
    @imgStep1.css(
      'top'   : "#{imgStep1Top}px"
    )

    # step 3 elements
    imgStep3Top = @spanStep3.position().top + 200
    @imgStep3.css(
      'top'  : "#{imgStep3Top}px"
    )
    divStep3Top = @spanStep3.position().top + 40
    @divStep3RuleTable.css(
      'top'  : "#{divStep3Top}px"
    )

    # step 4 elements
    imgIntPriorTop = @spanStep4.position().top + 147
    @imgIntPrior.css(
      'top'  : "#{imgIntPriorTop}px"
    )
    divIntRuleTableTop = @spanStep4.position().top + 370
    @divIntRuleTable.css(
      'top'  : "#{divIntRuleTableTop}px"
    )

    # fail message position
    failMsgTop = @buttonSubmit.position().top - 200
    @quizErrorMsg.css(
      'top'  : "#{failMsgTop}px"
    )

  showQuizFailedMsg: ->
    @quizErrorMsg.show()

  returnToQuizClicked: (ev) =>
    ev.preventDefault()
    @quizErrorMsg.hide()
    @render()

  randomizeRuleTable: (divId) ->
    if Network.payRandList is undefined
      Network.randomizePayList()

    trList = []
    tbody= $('div#' + divId).find('tbody')
    if tbody.length is 0
      return

    rows = tbody.children()
    firstRow = rows[0]
    secondRow = rows[1]

    # take out rows for randomization
    len = rows.length
    for num in [2..len]
      trList.push rows[num]

    # randomize row order
    newTrList = []
    for index in Network.payRandList[1]
      newTrList.push(trList[index])

    # randomize column order
    newTrList3 = [secondRow].concat newTrList

    for row in newTrList3
      tdList = $(row).children()

      newTdList = []
      for index in Network.payRandList[0]
        newTdList.push(tdList[index])

      tdLen = tdList.length
      for num in [(Network.payRandList[0].length)..tdLen]
        newTdList.push(tdList[num])

      $(row).contents().remove()
      for td in newTdList
        $(row).append(td)

    # put back randomized rows
    tbody.contents().remove()
    tbody.append(firstRow)
    for tr in newTrList3
      tbody.append(tr)


  toggleScreenshotClicked: (ev) =>
    ev.preventDefault()
    @imgScreenshot.slideToggle("slow")
    @divIntRuleTable.toggle("slow")
    @imgIntPrior.toggle("slow", =>
      # update position of fail message box
      failMsgTop = @buttonSubmit.position().top - 200
      @quizErrorMsg.css(
        'top' : "#{failMsgTop}px"
      )
    )

  goBackToTutorialClicked: (ev) =>
    ev.preventDefault()
    @navigate "/tutorial"

  submitClicked: (ev) =>
    ev.preventDefault()

    # for rendering
    checkedValues = []
    $('input:checkbox:checked').each ->
      checkedValues.push $(this).val()
    @checkedValues = checkedValues

    # get total num of questions
    total= $('input:checkbox').length
    # get num correct answers
    correct = @getNumCorrectAnswers()
    # console.log "score: #{correct}/#{total}"

    # get object to store quiz answers
    quizAnsObj = @getQuizAnsObj()
    # console.log "quiz answer object #{JSON.stringify(quizAnsObj)}"

    # get list of wrong answers
    @wrongAnswers = @listWrongQuestions()

    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
      @navigate '/task'
    else
      # For testing convenience.  TAKE OUT
      # correct = 14
      # total = 14

      # console.log "sending quiz results to server"
      Network.sendQuizInfo(correct, total, quizAnsObj)

  getQuizAnsObj: ->
    ansObj = {}

    $('input:checkbox').each ->
      n = $(this).attr('name')
      i = $(this).attr('id')
      if not ansObj[n]?
        ansObj[n] = {}
      if not ansObj[n][i]?
        ansObj[n][i] = {}

    for name in Object.keys(ansObj)
      for id in Object.keys(ansObj[name])
        ansObj[name][id]["value"] = $('input:checkbox#'+id).val()
        ansObj[name][id].checked = $('input:checkbox#'+id).is(':checked')
    ansObj

  getNumCorrectAnswers: ->
    # ids of checked choices
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

    return correct

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
    choices = $('div#q'+qNum+'choices')
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