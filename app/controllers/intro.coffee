Spine = require('spine')
Network = require 'network'

class Intro extends Spine.Controller
  className: 'intro'
  
  elements:
    ".tutorial .buttonPrev" : "pButtonPrev"
    ".tutorial .buttonNext" : "pButtonNext"
    ".tutorial .welcome" :    "divWelcome" # step 1 welcome message
    ".tutorial .jar"     :    "divJar"     # step 2 introduce mystery candy jar
    ".tutorial .twojars" :    "divTwoJars"
    ".tutorial .candy" : "divCandy"
    ".tutorial .report" : "divReport"
    ".tutorial .reward" : "divReward"
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
      @stepReward
      @stepGameSummary
      @stepOneSummary
      @stepOneNoteOne
      @stepTwoSummary
      @stepTwoNoteOne
      @stepTwoNoteTwo
      @stepThreeSummary
      @stepFourSummary
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

  stepSimple: (show, div) ->
    if show is true
      div.fadeIn()
    else 
      div.hide()
    return div

  # Step 1: show welcome message
  stepWelcome: (show) =>
    div = @divWelcome
    return @stepSimple(show, div)

  # Step 3: 
  stepTwoJars: (show) =>
    if show is true
      @divTwoJars.fadeIn()
      @imgJar.show()
      @imgJarA.fadeIn()
      @imgJarB.fadeIn()
    else
      @divTwoJars.hide()
      @imgJar.hide()
      @imgJarA.hide()
      @imgJarB.hide()
      
    return @divTwoJars


  # Step 2: show mystery candy jar
  stepJar: (show) =>
    if show is true
      @divJar.fadeIn()
      @imgJar.fadeIn()
    else
      @divJar.hide()
      @imgJar.hide()

    return @divJar

  stepCandy: (show) =>
    div = @divCandy
    return @stepSimple(show, div)

  stepReport: (show) =>
    div = @divReport
    return @stepSimple(show, div)

  stepReward: (show) =>
    div = @divReward
    return @stepSimple(show, div)


  stepGameSummary: (show) =>
    div = @divGameSummary
    return @stepSimple(show, div)

  stepOneSummary: (show) =>
    div = @divStepOneSummary
    return @stepSimple(show, div)
  
  stepOneNoteOne: (show) =>
    div = @divStepOneNoteOne
    return @stepSimple(show, div)

  stepTwoSummary: (show) =>
    div = @divStepTwoSummary
    return @stepSimple(show, div)

  stepTwoNoteOne: (show) =>
    div = @divStepTwoNoteOne
    return @stepSimple(show, div)
    
  stepTwoNoteTwo: (show) =>
    div = @divStepTwoNoteTwo
    return @stepSimple(show, div)
    
  stepThreeSummary: (show) =>
    div = @divStepThreeSummary
    return @stepSimple(show, div)

  stepFourSummary: (show) =>
    if show is true
      @elePaymentRule.fadeIn()
      @eleCurrPlayer.fadeIn()
      @eleArrowYou.fadeIn()
      @eleCurrPlayerReport.fadeIn()
      
      @elePlayerOne.fadeIn('slow')
      @elePlayerTwo.fadeIn('slow')
      
      # @elePlayerOne.effect("bounce", { times:10 }, 1000)
      # @elePlayerTwo.effect("bounce", { times:10 }, 1000)
      @elePlayerTwo.fadeOut('slow', => 
        @eleArrowOther.fadeIn('slow', =>
          @eleRefPlayerReport.fadeIn('slow', =>          
            @eleCurrPlayerReport.animate(
              {
                top: 350
                left: 290
              },
              {
                duration: 2000
                queue: false
              }
            )
              
            @eleRefPlayerReport.animate(
              {
                top: 350
                left: 390
              },
              {
                duration: 2000
                queue: false
              }
            )
          )
        )
      )
      
    else
      @elePaymentRule.hide()
      @eleCurrPlayer.hide()
      @eleArrowYou.hide()
      @eleCurrPlayerReport.hide()
      @elePlayerOne.hide()
      @elePlayerTwo.hide()
      @eleArrowOther.hide()
      @eleRefPlayerReport.hide()
      
      @eleCurrPlayerReport.css(
        {
          'position': 'absolute'
          'top':       '100px'
          'left':      '170px'
          'width':     '50px'
        }
      )

      @eleRefPlayerReport.css(
        {
          'position': 'absolute'
          'top':       '150px'
          'left':      '170px'
          'width':     '50px'
        }
      )

      
    div = @divStepFourSummary
    return @stepSimple(show, div)
    

  # generic function to get to the next step
  nextStep: (ev, currElement, nextElement) ->
    ev.preventDefault()
    currElement.hide()
    nextElement.fadeIn()

  # welcome message --> mystery jar
  finishWelcome: (ev) ->
    @nextStep ev, @infoStart, @infoJar
    @jar.fadeIn()

  # mystery jar --> 2 types of jars
  finishMysteryJar: (ev) ->
    @nextStep ev, @infoJar, @infoTypes
    @jarA.fadeIn()
    @jarB.fadeIn()
  
  # 2 types of jars --> step to reveal signal
  finishJarTypes: (ev) ->
    @nextStep ev, @infoTypes, @gameInterfaceStart
    
    @jar.hide()
    @jarA.hide() # hide jar A
    @jarB.hide() # hide jar B
    
    @tutorialDivResult.show() # show the result div
    @tutorialDivInfo.show()   # show the info div
    @tutorialSpanSignal.hide() # hide the signal
    @disableShowCandyButton = true
    @disableConfirmReportButton = true
    @divTutorial.animate
      # top: 300
      left: 430,
      1000
    
  finishGameInterfaceStart: (ev) ->
    @nextStep ev, @gameInterfaceStart, @gameInterfaceGameInfo
    @divTutorial.animate
      top: -10
      1000
    @boxGameInfo.fadeIn()
  
  finishGameInterfaceGameInfo: (ev) ->
    @nextStep ev, @gameInterfaceGameInfo, @gameRevealSignal
    @boxGameInfo.hide()
    @boxSignal.fadeIn()

  # step to reveal signal --> step to display click to reveal signal instruction
  finishRevealSignal: (ev) ->
    @nextStep ev, @gameRevealSignal, @gameClickForSignal
    @boxSignal.hide()
    @gameClickForSignalButton.hide() # hide next button
    @disableShowCandyButton = false

  # when reveal signal button is clicked
  showSignal: (e) ->
    e.preventDefault()
    if @disableShowCandyButton is false
      @tutorialSpanSignal.fadeIn()
      @tutorialSignalButton.hide() # hide button to reveal signal
      @gameClickForSignalButton.show() # show next button

  finishClickForSignal: (ev) ->
    @nextStep ev, @gameClickForSignal, @gameSignalImportantMessage
      
  finishSignalImportantMessage: (ev) ->
    @nextStep ev, @gameSignalImportantMessage, @gameChooseReport
    @boxReport.fadeIn()
  
  confirmReport: (e) ->
    e.preventDefault()
    if @disableConfirmReportButton is false
      @tutorialReportButton.hide()
      
  
  #t= step to choose report --> step to show rule
  finishChooseReport: (ev) ->
    @nextStep ev, @gameChooseReport, @gameRule
  
  nextGameRule: (ev) ->
    @nextStep ev, @gameRule, @last
    

    
module.exports = Intro