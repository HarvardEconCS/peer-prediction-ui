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
    # @tutorialAction = null
    # @defaultReport = Network.defaultOption
    # @tutorialSelected = @defaultReport

    @payAmounts = [0.58, 0.36, 0.43, 0.54]
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
    
    @divs = [
      'welcome'
      'twojars'
      'jar'
      'candy'
      'report'
      'summary'
    ]

  active: ->
    super
    @render()
    @stepShow()
        
  render: ->
    @signalList = Network.signalList unless @signalList
    @jarInfo = Network.jarInfo unless @jarInfo
    @html require('views/tutorial')(@)

  stepShow: ->
    @ele = $(".tutorial .#{@divs[@stepIndex]}")
    @ele.fadeIn()

    # possibly add the next button
    if @stepIndex < @divs.length - 1
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

    @stepFunctions[@stepIndex](true)
    
    
  # tear down the current step
  stepTeardown: ->
    @ele = $(".tutorial .#{@divs[@stepIndex]}")
    @ele.hide()
    
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

  # Step 1: show welcome message
  stepWelcome: (show) =>

  stepTwoJars: (show) =>
    if show is true
      $('img.tutorial1').css(
        'position': 'absolute'
        'top':      '0px'
        'left':     '400px'
      )
      $('img.tutorial1').show()
    else 
      $('img.tutorial1').css(
        'position': 'absolute'
        'top':      '0px'
        'left':     '400px'
      )
      $('img.tutorial1').hide()


  stepJar: (show) =>
    if show is true
      $('img.tutorial2').css(
        'position': 'absolute'
        'top':      '0px'
        'left':     '400px'
      )
      $('img.tutorial2').show()
    else 
      $('img.tutorial2').css(
        'position': 'absolute'
        'top':      '0px'
        'left':     '400px'
      )
      $('img.tutorial2').hide()


  stepCandy: (show) =>
    if show is true
      $('img#select_candy').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '400px'
      )
      $('img#select_candy').show()
      
      # if @ele.find(".button.animate").length 
      #   # animate button already exists
      # else
      #  @ele.append(@pButtonAnimate.contents().clone())
      #  
      # $('img#backdrop').css(
      #   'position': 'absolute'
      #   'top':      '0px'
      #   'left':     '400px'
      # )
      # $('img#robot').css(
      #   'position': 'absolute'
      #   'top':      '140px'
      #   'left':     '730px'
      # )
      # $('img#backdrop').show()
      # $('img#robot').show()

    else
      $('img#select_candy').hide()
      # $('img#backdrop').hide()
      # $('img#robot').hide()
      # $('img#p').hide()
      # $('img#mmbag').hide()

  stepReport: (show) =>
    if show is true
      $('img#compute_payment').css(
        'position': 'absolute'
        'top':      '50px'
        'left':     '400px'
      )
      $('img#compute_payment').show()
    else
      $('img#compute_payment').hide()

  stepSummary: (show) =>
 

    

    
module.exports = Tutorial