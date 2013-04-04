Spine = require('spine')
Network = require 'network'

class Notice extends Spine.Controller
  className: 'noticeCont'
  
  elements:
    "div#gameRuleReview" : "divReview"
    "div#treatmentNotice" : "divTreatment"
    "a#finishRuleReview" : "buttonRule"
  
  events:
    "click a#finishRuleReview" : "finishRuleReviewClicked"
    "click a#finishNotice" : "finishNoticeClicked"
  
  constructor: ->
    super
    @ruleDisplayed = true
    @ruleButtonDisplayed = false

  active: ->
    super
    @render()  
    
    # change to 15 seconds
    setTimeout ( => @showRuleButton()), 1000
    
  render: ->
    @html require('views/notice')(@)  
    
    if @ruleDisplayed is true
      @divReview.show()
      @divTreatment.hide()
    else 
      @divReview.hide()
      @divTreatment.show()
  
    if @ruleButtonDisplayed is true
      @buttonRule.show()
    else 
      @buttonRule.hide()
  
  showRuleButton: ->
    @buttonRule.show()
    
  finishRuleReviewClicked: (ev) =>
    ev.preventDefault()
    
    @divReview.hide()
    @divTreatment.show()
    
  finishNoticeClicked: (ev) =>
    ev.preventDefault()    
    
    if Network.fakeServer
      alert "This is only a preview!  Please ACCEPT the HIT to start working on this task!"
      @navigate '/task'
    else
      Network.sendQuizInfo(1, 1, null)

    
module.exports = Notice