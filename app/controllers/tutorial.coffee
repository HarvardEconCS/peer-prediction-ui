Spine = require('spine')

Network = require 'network'
Main  = require('controllers/main')

class Tutorial extends Spine.Controller
  className: 'tutorialCont'
  
  elements:
    ".tutorial .buttonPrev" : "pButtonPrev"
    ".tutorial .buttonNext" : "pButtonNext"
    
  events:
    "click .tutorial .button.next"  : "nextClicked"
    "click .tutorial .button.prev"  : "previousClicked"
    "click a#skipTutorial"          : "skipTutorialClicked"
    "click a#endTutorial"           : "endTutorialClicked"
    "click a#backToPageOne"         : "backToPageOneClicked" 
    "click a.fake"                  : "fakeButtonClicked"
 
  # does not do anything when fake button is clicked
  fakeButtonClicked: (ev) =>
    ev.preventDefault()
 
  # skip tutorial and go to quiz 
  skipTutorialClicked: (ev) =>
    ev.preventDefault()
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
    @navigate '/quiz'
    
  # end tutorial and go to quiz
  endTutorialClicked: (ev) =>
    ev.preventDefault()
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
    @navigate '/quiz'
 
  # go back to beginning of tutorial
  backToPageOneClicked: (ev) =>
    ev.preventDefault()
    @stepIndex = 0
    @render()
 
  constructor: ->
    super

    @signals = ['MM', 'GB']    
    # needs to be changed if actual payment rule changes.
    @payRule = [[0.90, 0.10, 1.50, 0.80],[0.80, 1.50, 0.10, 0.90]]

    @stepIndex = 0
    @steps = [
      ['welcome',     null]
      ['prior',       @stepTwoDescribePrior]
      ['takeCandy',   @stepThreeChooseCandy]
      ['gameRule',    @stepFourDescribeRule]
      ['recap',       @stepFiveRecap]
      ['uiStart',         @uiOneStart]
      ['uiGameActions',   @uiTwoGetCandy]
      ['uiChooseClaim',   @uiThreeSignalShown]
      ['uiOtherStatus',   @uiFourReportConfirmed]
      ['uiExperimentEnd', @uiSixExpEnd]
    ] 
    
    @tutOrgTop = '50px'
    @tutOrgLeft = '-10px'
    
    @picTop = '50px'
    @picLeft = '310px'
    
    @interfaceTop = '50px'
    @interfaceLeft = '0px'
    
  active: ->
    super
    @render()
  
  deactivate: ->
    super
    @stepIndex = 0

  render: ->
    @html require('views/tutorial')(@)
    
    # switch to current step
    @stepShow()

    # randomize order of rows in reward rule table
    @randomizeRuleTable('ruleTableTutorial')
    @randomizeRuleTable('int-task-ruleTable')

  stepShow: ->
    @ele = $(".tutorial .#{@steps[@stepIndex][0]}")
    @ele.fadeIn()

    # possibly add the next button
    if @stepIndex < @steps.length - 1
      # add next button
      if @ele.find(".button.next").length 
        # next button exists, do nothing
      else 
        @ele.prepend(@pButtonNext.contents().clone())
    else
      # TODO: add the go to task button
    
    # possibly add the prev button
    if @stepIndex > 0
      # add prev button
      if @ele.find(".button.prev").length 
        # prev button exists, do nothing
      else 
        @ele.prepend(@pButtonPrev.contents().clone())

    if @ele.find(".stepIndex").length
      # do nothing
    else 
      @ele.prepend("<span class=\"stepIndex\">(Page #{@stepIndex + 1}/#{@steps.length})</span>&nbsp;")
        
    @steps[@stepIndex][1]?(true)
    
  # tear down the current step
  stepTeardown: ->
    @ele = $(".tutorial .#{@steps[@stepIndex][0]}")
    @ele.hide()
    
    @steps[@stepIndex][1]?(false)

  # previous button clicked
  previousClicked: (ev) =>
    ev.preventDefault?()
  
    # tear down the current step
    @stepTeardown()
    
    # decrement step counter
    @stepIndex = @stepIndex - 1
    
    # show the previous step
    @stepShow()

  # next button clicked
  nextClicked: (ev) =>
    ev.preventDefault?()
  
    # tear down the current step
    @stepTeardown()
    
    if @stepIndex is @steps.length - 1
      # if current step is the last one, go to task page
      @navigate '/task'
    else 
      # increment the step counter and show next step
      @stepIndex = @stepIndex + 1
      @stepShow()
  
  showSelected: (show, selector) ->
     @img = $("img#{selector}")
     if show is true
       @img.css(
         'position': 'absolute'
         'top':      @picTop
         'left':     @picLeft
       )
       @img.fadeIn()
     else
       @img.hide()
    
  showSelectedCustom: (show, selector, locTop, locLeft) ->
     @img = $("img#{selector}")
     if show is true
       @img.css(
         'position': 'absolute'
         'top':      locTop
         'left':     locLeft
       )
       @img.fadeIn()
     else
       @img.hide()  
    
  showDiv: (show, selector, locTop, locLeft) ->
     @div = $("div#{selector}")
     if show is true
       @div.css(
         'top':      locTop
         'left':     locLeft
       )
       @div.show()
     else
       @div.hide() 
    
  stepTwoDescribePrior: (show) =>
        
    selector = "#step1"
    @showSelectedCustom show, selector, '50px', '320px' 
    
    selector = "#pic-prior"
    $("img#{selector}").css(
      'width' : '600px'
      'z-index' : '5'
    )
    @showSelectedCustom show, selector, '150px', '310px'

  stepThreeChooseCandy: (show) =>
    selector = "#step2"
    @showSelected(show, selector)
         
  stepFourDescribeRule: (show) =>
    selector = "#step3"
    @showSelected(show, selector)

    # do not display payment rule table for constant payment
    # selector = "#ruleTableTutorial"
    # @showDiv(show, selector, '270px', '40px')
    
  randomizeRuleTable: (divId) ->
    if Network.payRandList is undefined
      Network.randomizePayList()
    
    trList = []
    tbody= $('div#' + divId).find('tbody')
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


  stepFiveRecap: (show) =>
    selector = "#steps-recap"
    @showSelected(show, selector)

    selector = "#pic-prior"
    $("img#{selector}").css(
      'z-index':'5'
      'height': 'auto'
      'width':  '50%'
    )
    @showSelectedCustom(show, selector, '100px', '360px')

    # do not show payment rule table for constant payment
    # selector = "#ruleTableTutorial"
    # @showDiv(show, selector, '450px', '750px')

    # selector = "#eg-MM-GB"
    # @showSelectedCustom(show, selector, '600px', '450px')


  changeTaskPic: (show, picId, taskPicTop, taskPicLeft) =>
    @img = $("img##{picId}")
    @img.css(
      'position': 'absolute'
      'top':      taskPicTop
      'left':     taskPicLeft
    )
    if show is true
      @img.show()
    else
      @img.hide();

  changeTutorialPos: (show, topPos, leftPos) =>
    if show is true
      $('div.tutorial').css(
        'position': 'absolute'
        'top':      topPos
        'left':     leftPos
      )
    else
      $('div.tutorial').css(
        'position': 'absolute'
        'top':      @tutOrgTop
        'left':     @tutOrgLeft
      )

  uiOneStart: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'

    if show is true
      $('#int-task-status-getcandy').show()
      $('#int-task-status-confirmclaim').hide()
      $('#int-task-status-waitforclaims').hide()  
      $('#int-task-step3-v1').hide()
      $('#int-task-step3-v2').hide()     
      $('#int-task-ruleTable').hide() 
    else
      $('#int-task-status-getcandy').hide()
      $('#int-task-status-confirmclaim').hide()
      $('#int-task-status-waitforclaims').show()
      $('#int-task-step3-v1').show()
      $('#int-task-step3-v2').hide()  
      $('#int-task-ruleTable').show() 

    # @showSelectedCustom show, "#box-title", '10px', '230px'

    # change dialog position
    if show is true
      $('div.tutorial').animate
        top:  "+=240px"
        left: "+=520px"
        1000
    else
      $('div.tutorial').css(
        'position': 'absolute'
        'top':      @tutOrgTop
        'left':     @tutOrgLeft
      )   

  uiTwoGetCandy: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'
    
    if show is true
      $('#int-task-status-getcandy').show()
      $('#int-task-status-confirmclaim').hide()
      $('#int-task-status-waitforclaims').hide()
      $('#int-task-step3-v1').hide()
      $('#int-task-step3-v2').hide()    
      $('#int-task-ruleTable').hide() 
    else
      $('#int-task-status-getcandy').hide()
      $('#int-task-status-confirmclaim').hide()
      $('#int-task-status-waitforclaims').show()
      $('#int-task-step3-v1').show()
      $('#int-task-step3-v2').hide()  
      $('#int-task-ruleTable').show() 
    
    @changeTutorialPos show, '290px', '510px'
    @showSelectedCustom show, "#box-stepsonetwo", "65px", "-20px"
      
  uiThreeSignalShown: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'
    
    if show is true
      $('#int-task-step2-v1').hide()
      $('#int-task-step2-v2').show()   
      $('#t-nocandy').hide()
      $('#t-showcandy').show()      
      $('#int-task-status-getcandy').hide()
      $('#int-task-status-confirmclaim').show()
      $('#int-task-status-waitforclaims').hide()
       
    else
      $('#int-task-step2-v1').show()
      $('#int-task-step2-v2').hide()
      $('#t-nocandy').show()
      $('#t-showcandy').hide()  
      $('#int-task-status-getcandy').hide()
      $('#int-task-status-confirmclaim').hide()
      $('#int-task-status-waitforclaims').show()
  
    @changeTutorialPos show, '290px', '510px'
    @showSelectedCustom(show, "#box-stepthree", "310px", "-20px")
    
  uiFourReportConfirmed: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'

    if show is true
      $('#int-task-step2-v1').hide()
      $('#int-task-step2-v2').show()
      $('#int-task-step3-v1').hide()   
      $('#int-task-step3-v2').show()      
      $('#t-nocandy').hide()
      $('#t-showcandy').show()      
      # $('#t-noclaim').hide()
      # $('#t-showclaim').show()
      $('#int-task-status-getcandy').hide()
      $('#int-task-status-confirmclaim').show()
      $('#int-task-status-waitforclaims').hide()
      
    else
      $('#int-task-step2-v1').show()
      $('#int-task-step2-v2').hide()
      $('#int-task-step3-v1').show()      
      $('#int-task-step3-v2').hide()   
      $('#t-nocandy').show()
      $('#t-showcandy').hide()      
      # $('#t-noclaim').show()
      # $('#t-showclaim').hide()
      $('#int-task-status-getcandy').hide()
      $('#int-task-status-confirmclaim').hide()
      $('#int-task-status-waitforclaims').show()

    $('#box-onegame').css(
      'z-index': '3'
      )
    
    @changeTutorialPos show, '290px', '510px'
    @showSelectedCustom show, "#box-onegame", '215px', '490px'
    
  uiFiveResult: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'
    
    if show is true
      $('#int-task-step3-v1').hide()
      $('#int-task-step3-v2').hide()
      $('#int-task-ruleTable').hide() 
    else
      $('#int-task-step3-v1').show()
      $('#int-task-step3-v2').hide()
      $('#int-task-ruleTable').show() 
      
    $('#box-onegame').css(
      'z-index': '3'
      )

    @changeTutorialPos show, '290px', '510px'
    @showSelectedCustom show, "#box-onegame", '155px', '490px'
    
  uiSixExpEnd: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'
    
    if show is true
      $('#int-task-title').hide()
      $('#int-task-roundIndex').hide()
      $('#int-task-step1').hide()
      $('#int-task-step1pic').hide()
      $('#int-task-step2-v1').hide()
      $('#int-task-step3-v1').hide()
      $('#int-task-ruleTable').hide()
      $('#int-result-body-v1').hide()
      $('#int-result-body-v2').show()
      $('#r-zero').hide()
      $('#r-endgame').show()
      $('#int-finishmsg').show()
      $('#int-task-status-waitforclaims').hide()
    else
      $('#int-task-title').show()
      $('#int-task-roundIndex').show()
      $('#int-task-step1').show()
      $('#int-task-step1pic').show()
      $('#int-task-step2-v1').show()
      $('#int-task-step3-v1').show()
      $('#int-task-ruleTable').show()
      $('#int-result-body-v1').show()
      $('#int-result-body-v2').hide()
      $('#r-zero').show()
      $('#r-endgame').hide()
      $('#int-finishmsg').hide()
      $('#int-task-status-waitforclaims').show()
    
    $('div#int-result-body-v2').scrollTop($('div#int-result-body-v2').prop("scrollHeight"))
    
    @changeTutorialPos show, '300px', '100px'
    
 
    
module.exports = Tutorial