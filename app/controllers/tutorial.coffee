Spine = require('spine')

Network = require 'network'

class Tutorial extends Spine.Controller
  className: 'tutorialCont'
  
  elements:
    ".tutorial .buttonPrev"     : "pButtonPrev"
    ".tutorial .buttonNext"     : "pButtonNext"
    
  events:
    "click .tutorial .button.next"    : "nextClicked"
    "click .tutorial .button.prev"    : "previousClicked"
    'click a#endTutorial'             : "endTutorialClicked"
 
  endTutorialClicked: (ev) ->
    ev.preventDefault()
    @navigate '/quiz'
 
  constructor: ->
    super
    @payAmounts = [0.58, 0.36, 0.43, 0.54]
    @signalList = Network.signalList
    
    # $(document).keypress @keyPressed

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
    @stepShow()

  render: ->
    @signalList = Network.signalList unless @signalList
    @jarInfo = Network.jarInfo unless @jarInfo
    @html require('views/tutorial')(@)

  # navigate the tutorial using arrows
  keyPressed: (ev) =>
    ev.preventDefault()
    # console.log "key pressed is #{ev.which}"
    
    if ev.which is 102
      $(".tutorial .button.next:visible").click()
    else if ev.which is 100
      $(".tutorial .button.prev:visible").click()

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
      @ele.prepend("<span class=\"stepIndex\">(#{@stepIndex + 1}/#{@steps.length})</span>&nbsp;")
        
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
    
  stepTwoDescribePrior: (show) =>
    selector = "#tutorial1"
    @showSelected(show, selector)

  stepThreeChooseCandy: (show) =>
    selector = "#tutorial3"
    @showSelected(show, selector)
         
  stepFourDescribeRule: (show) =>
    selector = "#tutorial4"
    @showSelected(show, selector)

    selector = "#payment_rule"
    @showSelectedCustom(show, selector, '340px', '40px')

  stepFiveDescribeReward: (show) =>
    selector = "#tutorial7"
    @showSelected(show, selector)
    
    selector = "#payment_rule"
    @showSelectedCustom(show, selector, '250px', '40px')

  stepSixRecap: (show) =>
    selector = "#tutorial8"
    @showSelected(show, selector)


  changeTaskPic: (show, picId) =>
    @img = $("img##{picId}")
    @img.css(
      'position': 'absolute'
      'top':      @interfaceTop
      'left':     @interfaceLeft
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
    @changeTaskPic(show, 'taskstart')
    
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
    @changeTaskPic show, 'taskstart'
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom show, "#box-title", '10px', '230px'
    # @showSelectedCustom show, "#box-rewardrule", "365px", "65px"
  
  uiThreeActions: (show) =>
    @changeTaskPic show, 'taskstart'
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom show, "#box-stepsonetwo", "85px", "-20px"
      
  uiChooseClaim: (show) =>
    @changeTaskPic show, 'tasksignalshown'
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom(show, "#box-stepthree", "335px", "-20px")
    
  uiFourOtherStatus: (show) =>
    @changeTaskPic show, 'taskreportconfirmed'
    @changeTutorialPos show, '300px', '510px'
    @showSelectedCustom show, "#box-onegame", '185px', '490px'
    
  uiFiveResult: (show) =>
    @changeTaskPic show, 'tasknextgame'
    @changeTutorialPos show, '350px', '510px'
    @showSelectedCustom show, "#box-onegame", '184px', '490px'
    
  uiSixExpEnd: (show) =>
    @changeTaskPic(show, 'taskexpend')
    @changeTutorialPos(show, '300px', '100px')
    
    
    
    
    
      
  uiTwoGenInfo: (show) =>
    @changeTutorialPos(show, '55px', '453px')
    @changeTaskPic(show, 'taskstart')
    @showSelectedCustom(show, "#box-geninfo", '50px', '55px')

  uiThreePayRule: (show) =>   
    @changeTutorialPos(show, '325px', '340px')
    @changeTaskPic(show, 'taskstart')
    @showSelectedCustom(show, "#box-rule", '320px', '55px')

  uiFourInfoTable: (show) =>
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '55px', '55px')
    @showSelectedCustom(show, "#box-table", '50px', '350px')
    
  uiFivePastInfo: (show) =>
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '195px', '53px')
    @showSelectedCustom show, "#box-onepastgame", '180px', '340px'
    
  uiSixCurrInfo: (show) =>  
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos show, '340px', '200px'
    @showSelectedCustom show, "#box-signalReport", '100px', '95px'
    @showSelectedCustom show, "#box-onegame", '250px', '350px'
    
  uiSevenSignalButton: (show) =>
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '340px', '200px')
    @showSelectedCustom show, "#box-signal", '110px', '90px'
  
  uiEightSignalShown: (show) =>
    @changeTaskPic(show, 'tasksignalshown')
    @changeTutorialPos(show, '340px', '200px')
    @showSelectedCustom show, "#box-signal", '105px', '90px'
    @showSelectedCustom show, "#box-signalintable", '240px', '425px'
    
  stepUiReportChoice: (show) =>
    @changeTaskPic(show, 'taskchoosereport')
    @changeTutorialPos(show, '340px', '200px')
    @showSelectedCustom show, "#box-report", '160px', '90px'
    
  stepUiReportConfirmed: (show) =>
    @changeTaskPic(show, 'taskreportconfirmed')
    @changeTutorialPos(show, '340px', '200px')
    @showSelectedCustom show, "#box-signal", '160px', '90px'
    @showSelectedCustom show, "#box-signalintable", '240px', '495px'

  stepUiFriendStatus: (show) =>
    @changeTaskPic(show, 'taskfriendswaiting')
    @changeTutorialPos(show, '340px', '600px')
    @showSelectedCustom show, "#box-signal", '255px', '643px'
    
  stepUiFriendAllConfirmed: (show) =>
    @changeTaskPic(show, 'taskfriendsallconfirmed')
    @changeTutorialPos(show, '340px', '600px')
    @showSelectedCustom show, "#box-signal", '255px', '643px'

  stepUiNextGame: (show) =>
    @changeTaskPic(show, 'tasknextgame')
    @changeTutorialPos(show, '400px', '600px')
    @showSelectedCustom show, "#box-newgame", '250px', '340px'


 
    
module.exports = Tutorial