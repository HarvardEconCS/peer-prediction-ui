require('lib/setup')

Spine = require('spine')
Main  = require('controllers/main')
Network = require 'network'

class App extends Spine.Controller
  constructor: ->
    super
    
    if @isBrowserCompatible()
      Network.initFake()
      @main = new Main
      @append @main
      Spine.Route.setup()
    else 
      @html("<p>Sorry!  Your browser is incompatible with this site.  Please upgrade your browser.</p>")
    
  isBrowserCompatible: ->
    ua = $.browser
    version = parseInt(ua.version)
    if ua.msie && version < 9
      return false
    else 
      return true
  
module.exports = App
    