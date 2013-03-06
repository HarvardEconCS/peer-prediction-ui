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
    # no keyboard shortcuts for now
    # $(document).keypress @keyPressed

    # needs to be changed if actual payment rule changes.
    @payRule = [0.50, 0.10, 0.23, 0.43]
    @signals = ['MM', 'GB']

    @stepIndex = 0
    @steps = [
      ['welcome',     null]
      ['prior',       @stepTwoDescribePrior]
      ['takeCandy',   @stepThreeChooseCandy]
      ['gameRule',    @stepFourDescribeRule]
      ['example',     @stepFiveDescribeReward]
      ['recap',       @stepSixRecap]
      ['uiStart',           @uiOneStart]
      ['uiExperimentStart', @uiTwoExpStart]
      ['uiGameActions',     @uiThreeActions]
      ['uiChooseClaim',     @uiChooseClaim]
      ['uiOtherStatus',     @uiFourOtherStatus]
      ['uiGameResult',      @uiFiveResult]
      ['uiExperimentEnd',   @uiSixExpEnd]
    ] 
    
    @tutOrgTop = '50px'
    @tutOrgLeft = '10px'
    
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
  previousClicked: (ev) ->
    ev.preventDefault?()
  
    # tear down the current step
    @stepTeardown()
    
    # decrement step counter
    @stepIndex = @stepIndex - 1
    
    # show the previous step
    @stepShow()

  # next button clicked
  nextClicked: (ev) ->
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

  endTutorialClicked: (ev)->  
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
       @div.fadeIn()
     else
       @div.hide() 
    
  stepTwoDescribePrior: (show) =>
    selector = "#pic-prior"
    $("img#{selector}").css(
      'height' : 'auto'
    )
    @showSelected(show, selector)

  stepThreeChooseCandy: (show) =>
    selector = "#step2"
    @showSelected(show, selector)
         
  stepFourDescribeRule: (show) =>
    selector = "#step3-description"
    @showSelected(show, selector)

    # selector = "#payment_rule"
    # @showSelectedCustom(show, selector, '340px', '40px')

    selector = "#ruleTableTutorial"
    @showDiv(show, selector, '300px', '40px')

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
      'z-index' : 5
      'height' : '120px'
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
    @changeTaskPic show, 'taskstart', @interfaceTop, @interfaceLeft
    
    if show is true
      $('div.tutorial').animate
        top:  "+=250px"
        left: "+=500px"
        1000
    else
      $('div.tutorial').css(
        'position': 'absolute'
        'top':      @tutOrgTop
        'left':     @tutOrgLeft
      )   

    # @showSelectedCustom(show, "#box-tablenew", "95px", "400px")
 
  uiTwoExpStart: (show) =>
    @changeTaskPic show, 'taskstart', @interfaceTop, @interfaceLeft
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom show, "#box-title", '10px', '230px'
    # @showSelectedCustom show, "#box-rewardrule", "365px", "65px"
  
  uiThreeActions: (show) =>
    @changeTaskPic show, 'taskstart', @interfaceTop, @interfaceLeft
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom show, "#box-stepsonetwo", "85px", "-20px"
      
  uiChooseClaim: (show) =>
    @changeTaskPic show, 'tasksignalshown', @interfaceTop, '3px'
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom(show, "#box-stepthree", "335px", "-20px")
    
  uiFourOtherStatus: (show) =>
    @changeTaskPic show, 'taskreportconfirmed', @interfaceTop, '5px'
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom show, "#box-onegame", '185px', '490px'
    
  uiFiveResult: (show) =>
    @changeTaskPic show, 'tasknextgame', '51px', '6px'
    @changeTutorialPos show, '350px', '510px'
    @showSelectedCustom show, "#box-onegame", '184px', '490px'
    
  uiSixExpEnd: (show) =>
    @changeTaskPic show, 'taskexpend', @interfaceTop, '7px'
    @changeTutorialPos(show, '300px', '100px')
    
 
    
module.exports = Tutorial