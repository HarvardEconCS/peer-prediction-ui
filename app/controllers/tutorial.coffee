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
 
  constructor: ->
    super
    @payAmounts = [0.58, 0.36, 0.43, 0.54]
    @signalList = Network.signalList
    
    $(document).keypress @keyPressed

    @stepIndex = 0
    @steps = [
      ['welcome',     null]
      ['prior',       @stepPrior]
      ['takeCandy',   @stepTakeCandy]
      ['gameRule',    @stepGameRule]
      ['example',     @stepRewardExample]
      ['recap',       @stepRecap]
      ['uiStart',     @stepUiStart]
      ['uiGenInfo',   @stepUiGenInfo]
      ['uiPayRule',   @stepUiPayRule]
      ['uiInfoTable', @stepUiInfoTable]
      ['uiPastInfo',  @stepUiPastInfo]
      ['uiCurrInfo',  @stepUiCurrInfo]      
      ['uiSignalButton',    @stepUiSignalButton]
      ['uiSignalShown',     @stepUiSignalShown]
      ['uiReportChoice',    @stepUiReportChoice]
      ['uiReportConfirmed', @stepUiReportConfirmed]
      ['uiFriendStatus',    @stepUiFriendStatus]
      ['uiFriendAllConfirmed', @stepUiFriendAllConfirmed]
      ['uiNextGame', @stepUiNextGame]
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
      @ele.prepend("<span class=\"stepIndex\">#{@stepIndex + 1}/#{@steps.length}</span><br/><br/>")
        
        
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
    
  stepPrior: (show) =>
    if show is true
      $('img#tutorial1').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '390px'
      )
      $('img#tutorial1').fadeIn()
    else 
      $('img#tutorial1').hide()


  stepChooseWorld: (show) =>
    if show is true
      $('img#tutorial2').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '390px'
      )
      $('img#tutorial2').fadeIn()
    else 
      $('img#tutorial2').hide()


  stepTakeCandy: (show) =>
    if show is true
      $('img#tutorial3').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '390px'
      )
      $('img#tutorial3').fadeIn()
    else
      $('img#tutorial3').hide()

  stepGeneral: (show, selector) =>
    @img = $("img##{selector}")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '390px'
      )
      @img.fadeIn()
    else
      @img.hide()

  stepGameRule: (show) =>
    @img = $("img#tutorial4")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '390px'
      )
      @img.fadeIn()
    else
      @img.hide()

    @img2 = $("img#payment_rule")
    if show is true
      @img2.css(
        'position': 'absolute'
        'top':      '380px'
        'left':     '60px'
      )
      @img2.fadeIn()
    else
      @img2.hide()

  stepRewardExample: (show) =>
    @img = $("img#tutorial7")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '390px'
      )
      @img.fadeIn()
    else
      @img.hide()
      
    @img2 = $("img#payment_rule")
    if show is true
      @img2.css(
        'position': 'absolute'
        'top':      '280px'
        'left':     '60px'
      )
      @img2.fadeIn()
    else
      @img2.hide()


  stepRecap: (show) =>
    @img = $("img#tutorial8")
    if show is true
      @img.css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '390px'
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
    @changeTaskPic(show, 'taskstart')
    #@changeTutorialPos(show, '350px', '400px')
    if show is true
      $('div.tutorial').animate
        top: +350
        left: +340
        1000
    else
      $('div.tutorial').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '60px'
      )

  stepUiGenInfo: (show) =>
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '55px', '453px')
    
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
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '325px', '340px')

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
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '55px', '55px')
    
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
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '195px', '53px')
    
    @box = $('img#box-onepastgame')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '180px'
        'left':     '340px'
      )
      @box.fadeIn()
    else
      @box.hide()
    
  stepUiCurrInfo: (show) =>  
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '340px', '200px')
        
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

    
  stepUiSignalButton: (show) =>
    @changeTaskPic(show, 'taskstart')
    @changeTutorialPos(show, '340px', '200px')

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
    @changeTaskPic(show, 'tasksignalshown')
    @changeTutorialPos(show, '340px', '200px')
    
    @box = $('img#box-signal')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '105px'
        'left':     '90px'      
      )
      @box.fadeIn()
    else
      @box.hide()

    @box2 = $('img#box-signalintable')
    if show is true
      @box2.css(
        'position': 'absolute'
        'top':      '240px'
        'left':     '425px'      
      )
      @box2.fadeIn()
    else
      @box2.hide()
    
  stepUiReportChoice: (show) =>
    @changeTaskPic(show, 'taskchoosereport')
    @changeTutorialPos(show, '340px', '200px')
    
    @box = $('img#box-report')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '160px'
        'left':     '90px'      
      )
      @box.fadeIn()
    else
      @box.hide()
    
    
  stepUiReportConfirmed: (show) =>
    @changeTaskPic(show, 'taskreportconfirmed')
    @changeTutorialPos(show, '340px', '200px')
    
    @box = $('img#box-signal')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '160px'
        'left':     '90px'      
      )
      @box.fadeIn()
    else
      @box.hide()
      
    @box2 = $('img#box-signalintable')
    if show is true
      @box2.css(
        'position': 'absolute'
        'top':      '240px'
        'left':     '495px'      
      )
      @box2.fadeIn()
    else
      @box2.hide()  
    
  stepUiFriendStatus: (show) =>
    @changeTaskPic(show, 'taskfriendswaiting')
    @changeTutorialPos(show, '340px', '600px')
    
    @box = $('img#box-signal')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '255px'
        'left':     '643px'      
      )
      @box.fadeIn()
    else
      @box.hide()
    
  stepUiFriendAllConfirmed: (show) =>
    @changeTaskPic(show, 'taskfriendsallconfirmed')
    @changeTutorialPos(show, '340px', '600px')
    
    @box = $('img#box-signal')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '255px'
        'left':     '643px'      
      )
      @box.fadeIn()
    else
      @box.hide()
      
  stepUiNextGame: (show) =>
    @changeTaskPic(show, 'tasknextgame')
    @changeTutorialPos(show, '400px', '600px')
    
    @box = $('img#box-newgame')
    if show is true
      @box.css(
        'position': 'absolute'
        'top':      '250px'
        'left':     '340px'      
      )
      @box.fadeIn()
    else
      @box.hide()
    
    # @tab = $('div#help-tab')
    # if show is true
    #   @tab.fadeIn()
    # else
    #   @tab.hide()

 
    
module.exports = Tutorial