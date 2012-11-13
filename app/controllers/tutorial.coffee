Spine = require('spine')

Network = require 'network'

class Tutorial extends Spine.Controller
  className: 'tutorialController'
  
  elements:
    ".tutorial .buttonPrev" : "pButtonPrev"
    ".tutorial .buttonNext" : "pButtonNext"
    ".tutorial .welcome" :    "divWelcome" # step 1 welcome message
    ".tutorial .jar"     :    "divJar"     # step 2 introduce mystery candy jar
    ".tutorial .twojars" :    "divTwoJars"
    ".tutorial .candy" : "divCandy"
    ".tutorial .report" : "divReport"
    ".tutorial .summary" : "divSummary"
    ".tutorial .gameSummary"      : "divGameSummary"
    ".tutorial .stepOneSummary"   : "divStepOneSummary"
    ".tutorial .stepOneNoteOne"   : "divStepOneNoteOne"
    ".tutorial .stepTwoSummary"   : "divStepTwoSummary"
    ".tutorial .stepTwoNoteOne"   : "divStepTwoNoteOne"
    ".tutorial .stepTwoNoteTwo"   : "divStepTwoNoteTwo"
    ".tutorial .stepThreeSummary" : "divStepThreeSummary"
    ".tutorial .stepFourSummary"  : "divStepFourSummary"

    ".images .jar" :  "imgJar"
    ".images .jarA" : "imgJarA"
    ".images .jarB" : "imgJarB"

    ".elements .paymentRule" :  "elePaymentRule"
    ".elements .you"        : "eleCurrPlayer"
    ".elements .arrowYou"   : "eleArrowYou"
    ".elements .yourReport" : "eleCurrPlayerReport"
    
    ".elements .otherPlayerOne"  : "elePlayerOne"
    ".elements .otherPlayerTwo"  : "elePlayerTwo"
    ".elements .arrowOther"      : "eleArrowOther"
    ".elements .refPlayerReport" : "eleRefPlayerReport"
    

    # ".images .box-gameinfo" : "boxGameInfo"
    # ".images .box-signal"   : "boxSignal"
    # ".images .box-report"   : "boxReport"
    # 
    # ".images .tutorial-result" : "tutorialDivResult"
    # 
    # ".images .tutorial-info" : "tutorialDivInfo"
    # ".images .tutorial-info .signal" : "tutorialSpanSignal"
    # ".images .tutorial-info .tutorial-getsignal" : "tutorialSignalButton"
    # 
    # ".images .tutorial-info .tutorial-confirm" : "tutorialReportButton"
    
  events:
    "click .tutorial .button.next" : "nextClicked"
    "click .tutorial .button.prev" : "previousClicked"
    
    # "click .tutorial-info .confirm" : "confirmReport"
    # "click .tutorial-getsignal" : "showSignal"
    
  constructor: ->
    super
    @tutorialAction = null
    @defaultReport = Network.defaultOption
    @tutorialSelected = @defaultReport
    @payAmounts = [0.70, 0.48, 0.55, 0.66]
    @signalList = Network.signalList
    
    @stepIndex = 0
    @stepFunctions = [
      @stepWelcome
      @stepTwoJars
      @stepJar
      @stepCandy
      @stepReport
      @stepSummary
    ]



  active: ->
    super
    @render()
    @stepShow()
        
  render: ->
    @signalList = Network.signalList unless @signalList
    @jarInfo = Network.jarInfo unless @jarInfo
    @html require('views/tutorial')(@)



  # show the current step
  stepShow: ->
    @ele = @stepFunctions[@stepIndex](true)
    
    return unless @ele?

    if @stepIndex < @stepFunctions.length - 1
      # add next button
      if @ele.find(".button.next").length 
        # next button exists, do nothing
      else 
        @ele.prepend(@pButtonNext.contents().clone())
    else
      # TODO: add the go to task button
    
    if @stepIndex > 0
      # add prev button
      if @ele.find(".button.prev").length 
        # prev button exists, do nothing
      else 
        @ele.prepend(@pButtonPrev.contents().clone())
    
  # tear down the current step
  stepTeardown: ->
    @stepFunctions[@stepIndex](false)

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
    
    if @stepIndex is @stepFunctions.length - 1
      # if current step is the last one, go to task page
      @navigate '/task'
    else 
      # increment the step counter and show next step
      @stepIndex = @stepIndex + 1
      @stepShow()

  stepSimple: (show, divs) ->
    if show is true
      for div in divs
        div.fadeIn()
    else 
      for div in divs
        div.hide()
    return divs[0]

  # Step 1: show welcome message
  stepWelcome: (show) =>
    divs = [@divWelcome]
    $('div.welcome').effect("pulsate", {times:3}, 2000)
    return @stepSimple(show, divs)

  stepTwoJars: (show) =>
    divs = [@divTwoJars, $('div.tutorial1')]
    return @stepSimple(show, divs)

  stepJar: (show) =>
    divs = [@divJar, $('div.tutorial2')]
    return @stepSimple(show, divs)

  stepCandy: (show) =>
    divs = [@divCandy, $('div.tutorial3')]
    return @stepSimple(show, divs)

  stepReport: (show) =>
    divs = [@divReport]
    return @stepSimple(show, divs)

  stepSummary: (show) =>
    divs = [@divSummary]
    return @stepSimple(show, divs)
 
  nextGameRule: (ev) ->
    @nextStep ev, @gameRule, @last
    

    
module.exports = Tutorial