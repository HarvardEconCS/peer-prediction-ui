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
      
      # Network.initFake()
      Network.init()
      
      # dropdown = new Dropdown
      # @append dropdown
      # dropdown.active()
      
      @main = new Main
      @append @main
      Spine.Route.setup()

    
  isBrowserCompatible: ->
    ua = $.browser
    version = parseInt(ua.version)
    if ua.msie && version < 9
      return false
    else 
      return true
  
module.exports = App
    