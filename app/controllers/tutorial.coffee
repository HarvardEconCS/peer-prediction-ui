Spine = require('spine')

Network = require 'network'

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
    @navigate '/quiz'
    
  # end tutorial and go to quiz
  endTutorialClicked: (ev) =>
    ev.preventDefault()
    @navigate '/quiz'
 
  # go back to beginning of tutorial
  backToPageOneClicked: (ev) =>
    ev.preventDefault()
    @stepIndex = 0
    @render()
 
  constructor: ->
    super
    # needs to be changed if actual payment rule changes.
    @payRule = [0.50, 0.10, 0.23, 0.43]
    @signals = ['MM', 'GB']

    @stepIndex = 0
    @steps = [
      ['welcome',     null]
      ['prior',       @stepTwoDescribePrior]
      ['takeCandy',   @stepThreeChooseCandy]
      ['gameRule',    @stepFourDescribeRule]
      ['recap',       @stepSixRecap]
      ['uiStart',         @uiOneStart]
      ['uiGameActions',   @uiTwoGetCandy]
      ['uiChooseClaim',   @uiThreeSignalShown]
      ['uiOtherStatus',   @uiFourReportConfirmed]
      ['uiGameResult',    @uiFiveResult]
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
    @stepShow()

  # navigate the tutorial using arrows
  # keyPressed: (ev) =>
  #   ev.preventDefault()
  #   
  #   if ev.which is 102
  #     $(".tutorial .button.next:visible").click()
  #   else if ev.which is 100
  #     $(".tutorial .button.prev:visible").click()

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

  endTutorialClicked: (ev) =>  
    ev.preventDefault()
    @navigate '/quiz'
  
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
    )
    @showSelectedCustom show, selector, '200px', '310px'

  stepThreeChooseCandy: (show) =>
    selector = "#step2"
    @showSelected(show, selector)
         
  stepFourDescribeRule: (show) =>
    selector = "#step3"
    @showSelected(show, selector)

    selector = "#ruleTableTutorial"
    @showDiv(show, selector, '250px', '40px')

  stepFiveDescribeReward: (show) =>
    selector = "#step3-example"
    @showSelected(show, selector)
    
    selector = "#ruleTableTutorial"
    @showDiv(show, selector, '270px', '40px')

    selector = "#eg-MM-GB"
    @showSelectedCustom(show, selector, '440px', '320px')

    selector = "#eg-MM-MM"
    @showSelectedCustom(show, selector, '440px', '557px')

    selector = "#eg-GB-MM"
    @showSelectedCustom(show, selector, '440px', '782px')

  stepSixRecap: (show) =>
    selector = "#steps-recap"
    @showSelected(show, selector)

    selector = "#pic-prior"
    $("img#{selector}").css(
      'z-index':'5'
      'height': 'auto'
      'width':  '50%'
    )
    @showSelectedCustom(show, selector, '100px', '360px')
    
    selector = "#ruleTableTutorial"
    @showDiv(show, selector, '450px', '750px')

    selector = "#eg-MM-GB"
    @showSelectedCustom(show, selector, '600px', '450px')


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
      $('#status-getcandy').show()
      $('#status-confirmclaim').hide()
      $('#status-waitforclaims').hide()      
      $('#int-task-step3-v1').hide()
      $('#int-task-step3-v2').hide()     
      $('#int-task-ruleTable').hide() 
    else
      $('#status-getcandy').hide()
      $('#status-confirmclaim').hide()
      $('#status-waitforclaims').show()   
      $('#int-task-step3-v1').show()
      $('#int-task-step3-v2').hide()  
      $('#int-task-ruleTable').show() 

    @showSelectedCustom show, "#box-title", '10px', '230px'

    # change dialog position
    if show is true
      $('div.tutorial').animate
        top:  "+=260px"
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
      $('#status-getcandy').show()
      $('#status-confirmclaim').hide()
      $('#status-waitforclaims').hide()  
      $('#int-task-step3-v1').hide()
      $('#int-task-step3-v2').hide()    
      $('#int-task-ruleTable').hide() 
    else
      $('#status-getcandy').hide()
      $('#status-confirmclaim').hide()
      $('#status-waitforclaims').show()   
      $('#int-task-step3-v1').show()
      $('#int-task-step3-v2').hide()  
      $('#int-task-ruleTable').show() 
    
    @changeTutorialPos show, '310px', '510px'
    @showSelectedCustom show, "#box-stepsonetwo", "85px", "-20px"
      
  uiThreeSignalShown: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'
    
    if show is true
      $('#int-task-step2-v1').hide()
      $('#int-task-step2-v2').show()   
      $('#t-nocandy').hide()
      $('#t-showcandy').show()      
      $('#status-getcandy').hide()
      $('#status-confirmclaim').show()
      $('#status-waitforclaims').hide()      
    else
      $('#int-task-step2-v1').show()
      $('#int-task-step2-v2').hide()
      $('#t-nocandy').show()
      $('#t-showcandy').hide()  
      $('#status-getcandy').hide()
      $('#status-confirmclaim').hide()
      $('#status-waitforclaims').show()         
  
    @changeTutorialPos show, '310px', '510px'
    @showSelectedCustom(show, "#box-stepthree", "335px", "-20px")
    
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
      $('#t-noclaim').hide()
      $('#t-showclaim').show()
    else
      $('#int-task-step2-v1').show()
      $('#int-task-step2-v2').hide()
      $('#int-task-step3-v1').show()      
      $('#int-task-step3-v2').hide()   
      $('#t-nocandy').show()
      $('#t-showcandy').hide()      
      $('#t-noclaim').show()
      $('#t-showclaim').hide()

    $('#box-onegame').css(
      'z-index': '3'
      )
    
    @changeTutorialPos show, '310px', '510px'
    @showSelectedCustom show, "#box-onegame", '235px', '490px'
    
  uiFiveResult: (show) =>
    selector = "#interfaceTutorial"
    @showDiv show, selector, '0px', '0px'
    
    if show is true
      $('#r-zero').hide()
      $('#r-endgame').hide()
      $('#int-task-step3-v1').hide()
      $('#int-task-step3-v2').hide()
      $('#int-task-ruleTable').hide() 
    else
      $('#r-zero').show()
      $('#r-endgame').hide()
      $('#int-task-step3-v1').show()
      $('#int-task-step3-v2').hide()
      $('#int-task-ruleTable').show() 
      
    $('#box-onegame').css(
      'z-index': '3'
      )

    @changeTutorialPos show, '310px', '510px'
    @showSelectedCustom show, "#box-onegame", '175px', '490px'
    
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
      $('#r-nextgame').hide()
      $('#r-endgame').show()
      $('#int-finishmsg').show()
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
      $('#r-nextgame').hide()
      $('#r-endgame').hide()
      $('#int-finishmsg').hide()
    
    $('div#int-result-body-v2').scrollTop($('div#int-result-body-v2').prop("scrollHeight"))
    
    @changeTutorialPos show, '300px', '100px'
    
 
    
module.exports = Tutorial