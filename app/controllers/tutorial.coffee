Spine = require('spine')

Network = require 'network'

class Tutorial extends Spine.Controller
  className: 'tutorialController'
  
  elements:
    ".tutorial .buttonPrev"     : "pButtonPrev"
    ".tutorial .buttonNext"     : "pButtonNext"
    
  events:
    "click .tutorial .button.next"    : "nextClicked"
    "click .tutorial .button.prev"    : "previousClicked"
    
  constructor: ->
    super
    @left = '390px'

    @payAmounts = [0.58, 0.36, 0.43, 0.54]
    @signalList = Network.signalList
    
    $(document).keypress @keyPressed

    @stepIndex = 0
    @steps = [
      ['welcome',     null]
      ['prior',       @stepPrior]
      ['chooseWorld', @stepChooseWorld]
      ['takeCandy',   @stepTakeCandy]
      ['meetDad',     @stepMeetDad]
      ['strategic',   @stepStrategic]
      ['payRule',     @stepPayRule]
      ['example',     @stepExample]
      ['recap',       null]
      ['transition',  null]
      ['uiStart',     @stepUiStart]
      ['uiGenInfo',   @stepUiGenInfo]
      ['uiPayRule',   @stepUiPayRule]
      ['uiInfoTable', @stepUiInfoTable]
      ['uiPastInfo',  @stepUiPastInfo]
      ['uiCurrInfo',  @stepUiCurrInfo]      
      ['uiCurrStart',       @stepUiCurrStart]
      ['uiSignalButton',    @stepUiSignalButton]
      ['uiSignalShown',     @stepUiSignalShown]
      ['uiReportChoice',    @stepUiReportChoice]
      ['uiReportConfirmed', @stepUiReportConfirmed]
      ['uiFriendStatus',    @stepUiFriendStatus]
    ]

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
    
    if ev.which is 54
      $(".tutorial .button.next:visible").click()
    else if ev.which is 52
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

  stepPrior: (show) =>
    if show is true
      $('img#tutorial1').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      $('img#tutorial1').fadeIn()
    else 
      $('img#tutorial1').hide()


  stepChooseWorld: (show) =>
    if show is true
      $('img#tutorial2').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      $('img#tutorial2').fadeIn()
    else 
      $('img#tutorial2').hide()


  stepTakeCandy: (show) =>
    if show is true
      $('img#select_candy').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      $('img#select_candy').fadeIn()
    else
      $('img#select_candy').hide()

  stepGeneral: (show, selector) =>
    @img = $("img##{selector}")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      @img.fadeIn()
    else
      @img.hide()

  stepMeetDad: (show) =>
    @img = $("img#tutorial4")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      @img.fadeIn()
    else
      @img.hide()

  stepStrategic: (show) =>
    @img = $("img#tutorial5")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      @img.fadeIn()
    else
      @img.hide()
    
  stepPayRule: (show) =>
    @img = $("img#tutorial6")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      @img.fadeIn()
    else
      @img.hide()

  stepExample: (show) =>
    @img = $("img#tutorial7")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     @left
      )
      @img.fadeIn()
    else
      @img.hide()

  changeTaskPic: (show, picId) =>
    @img = $("img##{picId}")
    @img.css(
      'position': 'absolute'
      'top':      '50px'
      'left':     '50px'
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
        'top':      '50px'
        'left':     '60px'
      )

  stepUiStart: (show) =>
    @changeTaskPic(show, 'taskpic1')
    @changeTutorialPos(show, '300px', '400px')

  stepUiGenInfo: (show) =>
    @changeTaskPic(show, 'taskpic1')
    @changeTutorialPos(show, '55px', '455px')
    
    @box = $('img#box-geninfo')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '55px'
      )
      @box.fadeIn()
    else
      @box.hide()

  stepUiPayRule: (show) =>
    @changeTaskPic(show, 'taskpic1')
    @changeTutorialPos(show, '325px', '345px')

    @box = $('img#box-rule')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '320px'
        'left':     '55px'
      )
      @box.fadeIn()
    else
      @box.hide()

  stepUiInfoTable: (show) =>
    @changeTaskPic(show, 'taskpic4')
    @changeTutorialPos(show, '80px', '50px')
    
    @box = $('img#box-table')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '350px'
      )
      @box.fadeIn()
    else
      @box.hide()
    
  
  stepUiPastInfo: (show) =>
    @changeTaskPic(show, 'taskpic4')
    @changeTutorialPos(show, '80px', '50px')
    
    @box = $('img#box-onegame')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '190px'
        'left':     '350px'
      )
      @box.fadeIn()
    else
      @box.hide()
    
  stepUiCurrInfo: (show) =>  
    @changeTaskPic(show, 'taskpic4')
    @changeTutorialPos(show, '350px', '200px')
        
    @boxLeft = $('img#box-signalReport')
    @box = $('img#box-onegame')
    if show is true
      @boxLeft.css(
        'position': 'absolute'
        'top':      '100px'
        'left':     '95px'
      )
      @boxLeft.fadeIn()
      @box.css(
        'position': 'absolute'
        'top':      '250px'
        'left':     '350px'
      )
      @box.fadeIn()
    else
      @boxLeft.hide()
      @box.hide()    

  stepUiCurrStart: (show) =>
    @changeTaskPic(show, 'taskpic1')
    @changeTutorialPos(show, '350px', '200px')
    
  stepUiSignalButton: (show) =>
    @changeTaskPic(show, 'taskpic1')
    @changeTutorialPos(show, '350px', '200px')
  
    @box = $('img#box-signal')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '110px'
        'left':     '90px'      
      )
      @box.fadeIn()
    else
      @box.hide()
  
  stepUiSignalShown: (show) =>
    @changeTaskPic(show, 'taskpic2')
    @changeTutorialPos(show, '350px', '200px')
    
    @box = $('img#box-signal')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '110px'
        'left':     '90px'      
      )
      @box.fadeIn()
    else
      @box.hide()
    
  stepUiReportChoice: (show) =>

  stepUiReportConfirmed: (show) =>
    @changeTaskPic(show, 'taskpic1')
    @changeTutorialPos(show, '300px', '400px')
    
  stepUiFriendStatus: (show) =>

  stepSummary: (show) =>
    console.log "step summary is called"
 
    
module.exports = Tutorial