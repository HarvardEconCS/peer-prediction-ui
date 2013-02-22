require('lib/setup')

Spine = require('spine')
Main  = require('controllers/main')
Dropdown = require 'controllers/dropdown'
Network = require 'network'

class App extends Spine.Controller
  constructor: ->
    super
    
    if @isBrowserCompatible()

      # take out browser incompatibility warning 
      @html ''
      
      params = @getURLParams()
      if params['assignmentId'] is undefined
        Network.initFake()
      else
        Network.init()
      
      # Network.initFake()
      # Network.init()
      
      # dropdown = new Dropdown
      # @append dropdown
      # dropdown.active()
      
      @main = new Main
      @append @main
      Spine.Route.setup()
      Network.setMainController(@main)

    
  isBrowserCompatible: ->
    ua = $.browser
    version = parseInt(ua.version)
    if ua.msie && version < 9
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
    