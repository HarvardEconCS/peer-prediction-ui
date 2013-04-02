require('lib/setup')

Spine = require('spine')
Main  = require('controllers/main')
Network = require 'network'

class App extends Spine.Controller
  constructor: ->
    super
    
    if @isBrowserCompatible()

      # take out browser incompatibility warning 
      @html ''
                
      params = @getURLParams()      

      if not params.assignmentId
        # testing mode
        Network.fakeServer = true
      else if params.assignmentId is "ASSIGNMENT_ID_NOT_AVAILABLE"
        # preview mode
        Network.preview = true
        Network.fakeServer = true
      else
        # accepted mode
        Network.fakeServer = false
      
      @main = new Main
      @append @main      
      Spine.Route.setup()
      Network.setMainController(@main)
      
      if Network.fakeServer is false
        # accepted mode
        Network.init()      
    
  isBrowserCompatible: ->
    ua = $.browser
    version = parseInt(ua.version)    
    # if ua.msie && version < 9
    if ua.msie
      return false
    else 
      return true
  
  unescapeURL: (s) ->
    decodeURIComponent s.replace(/\+/g, "%20")
    
  getURLParams: ->
    params = {}
    m = window.location.href.match(/[\\?&]([^=]+)=([^&#]*)/g)
    if m
      i = 0
      while i < m.length
        a = m[i].match(/.([^=]+)=(.*)/)
        params[@unescapeURL(a[1])] = @unescapeURL(a[2])
        i++
    return params
  
module.exports = App
    